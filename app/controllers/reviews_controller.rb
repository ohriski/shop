class ReviewsController < ApplicationController
  before_action :set_product

  def create
    @review = @product.reviews.new(review_params.merge(user: Current.user))

    if @review.save
      redirect_to @product, notice: "Дякуємо за відгук!"
    else
      redirect_to @product, alert: @review.errors.full_messages.to_sentence
    end
  end

  def destroy
    reviews = admin? ? @product.reviews : @product.reviews.where(user: Current.user)
    reviews.find(params[:id]).destroy
    redirect_to @product, notice: "Відгук видалено"
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def review_params
    params.expect(review: %i[rating body])
  end
end
