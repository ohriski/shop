module Admin
  class DeliveryMethodsController < BaseController
    before_action :set_delivery_method, only: %i[edit update destroy]

    def index
      @delivery_methods = DeliveryMethod.order(:id)
    end

    def new
      @delivery_method = DeliveryMethod.new
    end

    def create
      @delivery_method = DeliveryMethod.new(delivery_method_params)

      if @delivery_method.save
        redirect_to admin_delivery_methods_path, notice: "Спосіб доставки додано"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @delivery_method.update(delivery_method_params)
        redirect_to admin_delivery_methods_path, notice: "Спосіб доставки оновлено"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @delivery_method.orders.exists?
        redirect_to admin_delivery_methods_path,
          alert: "Цей спосіб є в замовленнях. Вимкніть його замість видалення"
      else
        @delivery_method.destroy
        redirect_to admin_delivery_methods_path, notice: "Спосіб доставки видалено"
      end
    end

    private

    def set_delivery_method
      @delivery_method = DeliveryMethod.find(params[:id])
    end

    def delivery_method_params
      params.expect(delivery_method: %i[name price requires_address active])
    end
  end
end
