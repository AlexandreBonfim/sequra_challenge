class Api::V1::ReportsController < ApplicationController
  def disbursement_summary
    data = DisbursementReport.new.call

    respond_to do |format|
      format.json { render json: data }
      format.csv  { send_data DisbursementReportPresenter.new(data).to_csv, filename: "disbursement_summary.csv" }
    end
  end
end
