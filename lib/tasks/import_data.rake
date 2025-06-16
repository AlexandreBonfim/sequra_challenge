require "importers/merchant_importer"
require "importers/order_importer"

namespace :import do
  desc "Import merchants from CSV"
  task merchants: :environment do
    path = Rails.root.join("db/seeds/merchants.csv")
    Importers::MerchantImporter.new(path: path).import
  end

  desc "Import orders from CSV"
  task orders: :environment do
    path = Rails.root.join("db/seeds/orders.csv")
    Importers::OrderImporter.new(path: path).import
  end
end
