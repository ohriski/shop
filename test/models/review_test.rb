require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @product = products(:one)
  end

  def build_review(**attrs)
    Review.new({ user: @user, product: @product, rating: 5, body: "Чудовий товар" }.merge(attrs))
  end

  test "is valid with correct data" do
    assert build_review.valid?
  end

  test "rating must be between 1 and 5" do
    [ 0, 6, nil ].each do |rating|
      assert_not build_review(rating: rating).valid?
    end
  end

  test "requires body" do
    assert_not build_review(body: "").valid?
  end

  test "user can review a product only once" do
    build_review.save!
    duplicate = build_review

    assert_not duplicate.valid?
    assert duplicate.errors[:user_id].any?
  end

  test "same user can review different products" do
    build_review.save!
    assert build_review(product: products(:two)).valid?
  end

  test "average rating" do
    build_review(rating: 5).save!
    build_review(user: users(:two), rating: 2).save!
    assert_equal 3.5, @product.average_rating
  end

  test "average rating is 0 without reviews" do
    assert_equal 0, @product.average_rating
  end

  test "author name does not reveal the email domain" do
    assert_equal @user.email_address.split("@").first, build_review.author_name
  end

  test "deleting a product removes its reviews" do
    build_review.save!
    assert_difference("Review.count", -1) do
      @product.destroy
    end
  end
end
