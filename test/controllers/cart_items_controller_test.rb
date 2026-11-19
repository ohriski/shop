require "test_helper"

class CartItemsControllerTest < ActionDispatch::IntegrationTest
  test "guest can add a product to the cart" do
    assert_difference("CartItem.count", 1) do
      post cart_items_url, params: { product_id: products(:one).id }
    end
    assert_redirected_to products_url
  end

  test "adding the same product twice increases quantity" do
    2.times { post cart_items_url, params: { product_id: products(:one).id } }
    assert_equal 1, CartItem.count
    assert_equal 2, CartItem.first.quantity
  end

  test "cannot add more than the stock" do
    4.times { post cart_items_url, params: { product_id: products(:one).id } }
    assert_equal 3, CartItem.first.quantity
  end

  test "empty cart page" do
    get cart_url
    assert_response :success
    assert_match "Ваш кошик порожній", response.body
  end

  test "cart page shows added product" do
    post cart_items_url, params: { product_id: products(:one).id }
    get cart_url
    assert_response :success
    assert_match products(:one).name, response.body
  end

  test "can update quantity" do
    post cart_items_url, params: { product_id: products(:one).id }
    item = CartItem.first
    patch cart_item_url(item), params: { cart_item: { quantity: 2 } }
    assert_redirected_to cart_url
    assert_equal 2, item.reload.quantity
  end

  test "can remove an item" do
    post cart_items_url, params: { product_id: products(:one).id }
    assert_difference("CartItem.count", -1) do
      delete cart_item_url(CartItem.first)
    end
  end

  test "cannot change an item from another cart" do
    other_item = Cart.create!.cart_items.create!(product: products(:two), quantity: 1)
    post cart_items_url, params: { product_id: products(:one).id }

    patch cart_item_url(other_item), params: { cart_item: { quantity: 5 } }
    assert_response :not_found
    assert_equal 1, other_item.reload.quantity
  end

  test "browsing the catalog does not create a cart" do
    assert_no_difference("Cart.count") do
      get products_url
    end
  end
end
