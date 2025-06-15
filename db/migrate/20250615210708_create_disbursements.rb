class CreateDisbursements < ActiveRecord::Migration[8.0]
  def change
    create_table :disbursements do |t|
      t.string :reference, null: false, index: { unique: true }
      t.date :date, null: false
      t.decimal :total_amount, null: false, precision: 10, scale: 2
      t.decimal :total_fees, null: false, precision: 10, scale: 2
      t.references :merchant, type: :uuid,  foreign_key: true
      t.timestamps
    end
  end
end
