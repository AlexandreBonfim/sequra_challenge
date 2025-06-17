class DailyDisbursementWorker
  include Sidekiq::Worker

  def perform
    DisbursementCreator.call(Date.current)
  end
end
