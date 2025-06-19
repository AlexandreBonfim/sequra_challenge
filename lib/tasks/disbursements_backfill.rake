require "ruby-progressbar"
require "benchmark"
require "concurrent"
require "set"

namespace :disbursements do
  desc "Backfill disbursements for undisbursed orders in batches"
  task backfill: :environment do
    puts "🔍 Starting disbursement backfill..."

    time = Benchmark.measure do
      # First, get the total count for accurate progress tracking
      total_undisbursed = Order.where(disbursement_id: nil).count
      puts "📦 Found #{total_undisbursed} undisbursed orders"

      if total_undisbursed == 0
        puts "✅ No undisbursed orders found!"
        return
      end

      # Get all unique merchant-date combinations that need disbursements
      merchant_date_combinations = Order.where(disbursement_id: nil)
                                       .joins(:merchant)
                                       .select("DISTINCT merchants.id as merchant_id, merchants.disbursement_frequency, merchants.live_on, merchants.reference, DATE(orders.ordered_at) as order_date")
                                       .where("merchants.disbursement_frequency IN (?)", [ Merchant::DISBURSEMENT_FREQUENCY_DAILY, Merchant::DISBURSEMENT_FREQUENCY_WEEKLY ])

      # Filter eligible combinations
      eligible_combinations = []
      merchant_date_combinations.each do |combo|
        merchant = {
          id: combo.merchant_id,
          disbursement_frequency: combo.disbursement_frequency,
          live_on: combo.live_on,
          reference: combo.reference
        }
        date = combo.order_date.to_date

        if eligible_for_disbursement?(merchant, date)
          eligible_combinations << { merchant: merchant, date: date }
        end
      end

      puts "📅 Found #{eligible_combinations.size} eligible merchant-date combinations"

      # Check for existing disbursements in bulk
      existing_keys = Disbursement.where(
        merchant_id: eligible_combinations.map { |c| c[:merchant][:id] },
        date: eligible_combinations.map { |c| c[:date] }
      ).pluck(:merchant_id, :date).to_set

      # Filter out existing disbursements
      to_process = eligible_combinations.reject do |combo|
        existing_keys.include?([ combo[:merchant][:id], combo[:date] ])
      end

      puts "🔄 Processing #{to_process.size} new disbursements in parallel..."

      progress = ProgressBar.create(
        title: "Backfilling Disbursements",
        total: to_process.size,
        format: "%t |%B| %c/%C"
      )

      # Use thread pool for parallel processing
      thread_pool = Concurrent::FixedThreadPool.new(8)
      results = Concurrent::Array.new
      mutex = Mutex.new

      to_process.each do |combo|
        thread_pool.post do
          begin
            result = process_disbursement_batch(combo[:merchant], combo[:date])
            mutex.synchronize do
              results << result
              progress.increment
            end
          rescue => e
            puts "❌ Error processing #{combo[:merchant][:id]}-#{combo[:date]}: #{e.message}"
          end
        end
      end

      thread_pool.shutdown
      thread_pool.wait_for_termination

      disbursements_created = results.sum { |r| r[:disbursements_created] }
      orders_updated = results.sum { |r| r[:orders_updated] }

      puts "📊 Disbursements created: #{disbursements_created}"
      puts "📦 Orders updated: #{orders_updated}"
    end

    puts "✅ Finished in #{time.real.round(2)} seconds"
  end

  private

  def process_disbursement_batch(merchant, date)
    # Get all orders for this merchant and date
    orders = Order.where(disbursement_id: nil, merchant_id: merchant[:id])
                  .where("DATE(ordered_at) = ?", date)
                  .to_a

    return { disbursements_created: 0, orders_updated: 0 } if orders.empty?

    # Use database-level uniqueness check to prevent race conditions
    reference = ReferenceGenerator.disbursement_reference(merchant)

    # Try to create disbursement with unique constraint
    begin
      disbursement = Disbursement.create!(
        merchant_id: merchant[:id],
        date: date,
        reference: reference,
        total_amount: 0,
        total_fees: 0
      )
    rescue ActiveRecord::RecordNotUnique
      # Another thread already created this disbursement
      return { disbursements_created: 0, orders_updated: 0 }
    end

    # Calculate totals and update orders
    total_amount = BigDecimal("0")
    total_fees = BigDecimal("0")

    orders.each do |order|
      fee = FeeCalculator.calculate(order.amount)
      net = (order.amount - fee).round(2)

      total_fees += fee
      total_amount += net

      order.update!(disbursement_id: disbursement.id)
    end

    disbursement.update!(
      total_amount: total_amount.round(2),
      total_fees: total_fees.round(2)
    )

    { disbursements_created: 1, orders_updated: orders.size }
  end

  def eligible_for_disbursement?(merchant, date)
    case merchant[:disbursement_frequency]
    when Merchant::DISBURSEMENT_FREQUENCY_DAILY
      true
    when Merchant::DISBURSEMENT_FREQUENCY_WEEKLY
      merchant[:live_on].wday == date.wday
    else
      false
    end
  end
end
