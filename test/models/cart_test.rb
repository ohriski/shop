require "test_helper"

class CartTest < ActiveSupport::TestCase
  setup do
    @cart = Cart.create!
  end

  test "adds a product to the cart" do
    item = @cart.add_product(products(:one), 2)
    assert item.persisted?
    assert_equal 2, @cart.total_quantity
  end

  test "adding the same product again increases quantity" do
    @cart.add_product(products(:one), 1)
    @cart.add_product(products(:one), 1)
    assert_equal 1, @cart.cart_items.count
    assert_equal 2, @cart.cart_items.first.quantity
  end

  test "calculates total price" do
    @cart.add_product(products(:one), 2) # 2 x 10.50
    @cart.add_product(products(:two), 1) # 1 x 20.00
    assert_equal 41, @cart.total_price
  end

  test "cannot add more than the stock" do
    item = @cart.add_product(products(:one), 4) # на складі 3
    assert item.errors[:quantity].any?
    assert_equal 0, @cart.cart_items.count
  end

  test "quantity cannot exceed stock when increasing" do
    @cart.add_product(products(:one), 3)
    item = @cart.add_product(products(:one), 1)
    assert item.errors[:quantity].any?
    assert_equal 3, @cart.cart_items.first.quantity
  end

  test "deleting a product removes it from carts" do
    @cart.add_product(products(:one), 1)
    assert_difference("CartItem.count", -1) do
      products(:one).destroy
    end
  end
end
