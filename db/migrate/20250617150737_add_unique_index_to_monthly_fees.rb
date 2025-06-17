class AddUniqueIndexToMonthlyFees < ActiveRecord::Migration[8.0]
  def change
    add_index :monthly_fees, [ :merchant_id, :year, :month ], unique: true
  end
end
