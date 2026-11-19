require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "is invalid without a name" do
    product = Product.new(price: 10, stock: 1, category: categories(:mice))
    assert_not product.valid?
  end

  test "is invalid with a duplicate name" do
    product = Product.new(name: products(:one).name, price: 10, stock: 1, category: categories(:mice))
    assert_not product.valid?
  end

  test "is invalid with a non-positive price" do
    product = Product.new(name: "Free item", price: 0, stock: 1, category: categories(:mice))
    assert_not product.valid?
  end

  test "is invalid with a negative stock" do
    product = Product.new(name: "Broken stock", price: 10, stock: -1, category: categories(:mice))
    assert_not product.valid?
  end

  test "is invalid without a category" do
    product = Product.new(name: "No category", price: 10, stock: 1)
    assert_not product.valid?
  end

  test "is valid with correct data" do
    product = Product.new(name: "Valid item", price: 10, stock: 1, category: categories(:mice))
    assert product.valid?
  end
end
