require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "is invalid without a name" do
    assert_not Category.new.valid?
  end

  test "is invalid with a duplicate name" do
    assert_not Category.new(name: categories(:mice).name).valid?
  end

  test "cannot be destroyed while it has products" do
    category = categories(:mice)
    assert_not category.destroy
    assert Category.exists?(category.id)
  end
end
