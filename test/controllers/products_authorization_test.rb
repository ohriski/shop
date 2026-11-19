require "test_helper"

class ProductsAuthorizationTest < ActionDispatch::IntegrationTest
  def product_params
    { product: { category_id: categories(:mice).id, name: "Hacked Product", description: "x", price: 10, stock: 1 } }
  end

  test "guest can view catalog" do
    get products_url
    assert_response :success
  end

  test "guest can view a product" do
    get product_url(products(:one))
    assert_response :success
  end

  test "guest is redirected to login when creating a product" do
    assert_no_difference("Product.count") do
      post products_url, params: product_params
    end
    assert_redirected_to new_session_url
  end

  test "regular user cannot open the new product form" do
    sign_in_as users(:one)
    get new_product_url
    assert_redirected_to root_url
  end

  test "regular user cannot create a product" do
    sign_in_as users(:one)
    assert_no_difference("Product.count") do
      post products_url, params: product_params
    end
    assert_redirected_to root_url
  end

  test "regular user cannot delete a product" do
    sign_in_as users(:one)
    assert_no_difference("Product.count") do
      delete product_url(products(:one))
    end
    assert_redirected_to root_url
  end

  test "regular user does not see management buttons on product page" do
  sign_in_as users(:one)
  get product_url(products(:one))
  assert_select "a", text: "Редагувати", count: 0
  assert_select "button", text: "Видалити", count: 0
end

test "admin sees management buttons on product page" do
  sign_in_as users(:admin)
  get product_url(products(:one))
  assert_select "a", text: "Редагувати"
  assert_select "button", text: "Видалити"
end
end
