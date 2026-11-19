class AddPaymentToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :payment_method, :integer, null: false, default: 0
    add_column :orders, :paid_at, :datetime
    add_column :orders, :payment_reference, :string
  end
end
