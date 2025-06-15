class CreateMerchants < ActiveRecord::Migration[8.0]
  def change
    create_table :merchants, id: :uuid do |t|
      t.string :reference, null: false
      t.string :email, null: false
      t.date :live_on, null: false
      t.string :disbursement_frequency, null: false
      t.decimal :minimum_monthly_fee, null: false, precision: 10, scale: 2

      t.timestamps
    end
  end
end
