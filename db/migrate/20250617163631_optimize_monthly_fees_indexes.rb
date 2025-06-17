class OptimizeMonthlyFeesIndexes < ActiveRecord::Migration[8.0]
  def change
    # Remove the redundant simple index on merchant_id
    # The composite index (merchant_id, year, month) can handle queries on merchant_id alone
    remove_index :monthly_fees, :merchant_id, if_exists: true
<<<<<<< HEAD
=======

    # Ensure the composite unique index exists
    add_index :monthly_fees, [ :merchant_id, :year, :month ], unique: true, if_not_exists: true
>>>>>>> c01e119 (refactor: optimize monthly fees: remove redundant index, fix calculator)
  end
end
