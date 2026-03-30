class CreateRefunds < ActiveRecord::Migration[8.0]
  def change
    create_table :refunds do |t|
      t.references :order, null: false
      t.references :disbursement

      t.decimal :amount, null: false
      t.datetime :refund_at, null: false

      t.timestamps
    end
  end
end


# check out money gem 