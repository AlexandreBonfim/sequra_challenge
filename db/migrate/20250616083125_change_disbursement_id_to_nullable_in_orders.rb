class ChangeDisbursementIdToNullableInOrders < ActiveRecord::Migration[8.0]
  def change
    change_column_null :orders, :disbursement_id, true
  end
end
