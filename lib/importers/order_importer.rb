require "importers/base_importer"
require "set"

module Importers
  class OrderImporter < BaseImporter
    def initialize(path:, batch_size: 5000)
      super
      @missing_merchants = Set.new
    end

    def import
      super
      report_missing_merchants
    end

    private

    def model
      Order
    end

    def process_row(row, rows, current_time)
      merchant = merchants_by_reference[row["merchant_reference"]]

      unless merchant
        @missing_merchants << row["merchant_reference"] unless @missing_merchants.include?(row["merchant_reference"])
        return
      end

      rows << {
        id: row["id"],
        amount: row["amount"].to_d,
        ordered_at: row["created_at"],
        merchant_reference: row["merchant_reference"],
        merchant_id: merchant.id,
        created_at: current_time,
        updated_at: current_time
      }

      if rows.size >= batch_size
        model.insert_all!(rows, returning: false)
        rows.clear
      end
    end

    def merchants_by_reference
      @merchants_by_reference ||= Merchant.all.index_by(&:reference)
    end

    def report_missing_merchants
      if @missing_merchants.any?
        puts "⚠️  The following merchants were not found: #{@missing_merchants.to_a.join(', ')}"
      end
    end
  end
end
