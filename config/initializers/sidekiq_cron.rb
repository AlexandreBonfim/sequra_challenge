require "sidekiq/cron"

Sidekiq::Cron::Job.create(
  name: "Daily disbursement - every day at 7:00 UTC",
  cron: "0 7 * * *", # every day at 7:00 UTC
  class: "DailyDisbursementWorker"
)

Sidekiq::Cron::Job.create(
  name: "Monthly fee - 1st of month at 7:30 UTC",
  cron: "30 7 1 * *", # 1st of the month at 07:30 UTC
  class: "MonthlyFeeWorker"
)
