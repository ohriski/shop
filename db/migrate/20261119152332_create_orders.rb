class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
  t.references :user, null: false, foreign_key: true
  t.integer :status, null: false, default: 0
  t.decimal :total_price, precision: 10, scale: 2, null: false, default: 0
  t.string :customer_name, null: false
  t.string :phone, null: false
  t.timestamps
end
  end
end
