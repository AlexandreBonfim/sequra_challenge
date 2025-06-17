namespace :monthly_fees do
  desc "Backfill monthly fees for all merchants for all months with orders"
  task backfill: :environment do
    first_order = Order.order(:ordered_at).first
    last_order = Order.order(:ordered_at).last

    unless first_order && last_order
      puts "❌ No orders found in the database."
      exit 1
    end

    start_date = first_order.ordered_at.to_date.beginning_of_month
    end_date = last_order.ordered_at.to_date.beginning_of_month

    current_date = start_date

    puts "📊 Calculating monthly fees from #{start_date} to #{end_date}..."

    while current_date <= end_date
      year = current_date.year
      month = current_date.month
      puts "  - Processing #{year}-#{month.to_s.rjust(2, '0')}"
      MonthlyFeeCalculator.call(year: year, month: month)
      current_date = current_date.next_month
    end

    puts "✅ Done!"
  end
end
