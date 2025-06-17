class MonthlyFeeWorker
  include Sidekiq::Worker

  def perform
    today = Date.current
    previous_month = today.prev_month

    MonthlyFeeCalculator.call(year: previous_month.year, month: previous_month.month)
  end
end
