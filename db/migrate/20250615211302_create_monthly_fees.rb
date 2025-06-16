class CreateMonthlyFees < ActiveRecord::Migration[8.0]
  def change
    create_table :monthly_fees do |t|
      t.references :merchant, null: false, foreign_key: true, type: :uuid
      t.integer :year, null: false
      t.integer :month, null: false
      t.decimal :amount, null: false, precision: 10, scale: 2

      t.timestamps
    end
  end
end
