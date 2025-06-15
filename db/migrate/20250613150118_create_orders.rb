class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders, id: false do |t|
      t.string :id, primary_key: true
      t.decimal :amount, null: false
      t.datetime :ordered_at, null: false
      t.string :merchant_reference, null: false
      t.references :merchant, type: :uuid, foreign_key: true
      t.timestamps
    end
  end
end
