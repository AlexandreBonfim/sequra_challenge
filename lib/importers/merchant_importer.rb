require "importers/base_importer"

module Importers
  class MerchantImporter < BaseImporter
    private

    def model
      Merchant
    end

    def process_row(row, rows, current_time)
      rows << {
        id: row["id"],
        reference: row["reference"],
        email: row["email"],
        live_on: row["live_on"],
        disbursement_frequency: row["disbursement_frequency"].downcase,
        minimum_monthly_fee: row["minimum_monthly_fee"].to_d,
        created_at: current_time,
        updated_at: current_time
      }

      if rows.size >= batch_size
        model.insert_all!(rows, returning: false)
        rows.clear
      end
    end
  end
end
