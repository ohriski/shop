require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
  end

  test "guest is redirected to login" do
    assert_no_difference("Review.count") do
      post product_reviews_url(@product), params: { review: { rating: 5, body: "Супер" } }
    end
    assert_redirected_to new_session_url
  end

  test "user can leave a review" do
    sign_in_as users(:one)

    assert_difference("Review.count", 1) do
      post product_reviews_url(@product), params: { review: { rating: 4, body: "Гарний товар" } }
    end
    assert_redirected_to product_url(@product)
  end

  test "invalid review is not saved" do
    sign_in_as users(:one)

    assert_no_difference("Review.count") do
      post product_reviews_url(@product), params: { review: { rating: 9, body: "" } }
    end
    assert_redirected_to product_url(@product)
  end

  test "cannot review the same product twice" do
    sign_in_as users(:one)
    post product_reviews_url(@product), params: { review: { rating: 4, body: "Перший" } }

    assert_no_difference("Review.count") do
      post product_reviews_url(@product), params: { review: { rating: 5, body: "Другий" } }
    end
  end

  test "product page shows reviews" do
    Review.create!(user: users(:two), product: @product, rating: 5, body: "Дуже задоволений покупкою")

    get product_url(@product)
    assert_response :success
    assert_match "Дуже задоволений покупкою", response.body
  end

  test "user can delete own review" do
    sign_in_as users(:one)
    review = Review.create!(user: users(:one), product: @product, rating: 3, body: "Нормально")

    assert_difference("Review.count", -1) do
      delete product_review_url(@product, review)
    end
    assert_redirected_to product_url(@product)
  end

  test "user cannot delete someone else's review" do
    sign_in_as users(:one)
    review = Review.create!(user: users(:two), product: @product, rating: 3, body: "Нормально")

    assert_no_difference("Review.count") do
      delete product_review_url(@product, review)
    end
    assert_response :not_found
  end

  test "admin can delete any review" do
    admin = users(:one)
    admin.update!(admin: true)
    sign_in_as admin
    review = Review.create!(user: users(:two), product: @product, rating: 1, body: "Спам")

    assert_difference("Review.count", -1) do
      delete product_review_url(@product, review)
    end
  end
end
