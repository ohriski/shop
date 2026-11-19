class ProfilesController < ApplicationController
  def show
    @user = Current.user
    @orders = @user.orders.order(created_at: :desc)
  end

  def edit
    @user = Current.user
  end

  def update
    # Окремий екземпляр, щоб при помилці не псувались дані в навігації
    @user = User.find(Current.user.id)

    if sensitive_change? && !@user.authenticate(params.dig(:user, :current_password).to_s)
      @user.assign_attributes(profile_params.except(:password, :password_confirmation))
      @user.errors.add(:base, "Поточний пароль введено невірно")
      render :edit, status: :unprocessable_entity
    elsif @user.update(profile_params)
      @user.sessions.where.not(id: Current.session.id).destroy_all if profile_params[:password].present?
      redirect_to profile_path, notice: "Профіль оновлено"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    @profile_params ||= params.expect(user: %i[name phone email_address password password_confirmation]).tap do |permitted|
      if permitted[:password].blank?
        permitted.delete(:password)
        permitted.delete(:password_confirmation)
      end
    end
  end

  # Зміна пароля або email потребує підтвердження поточним паролем
  def sensitive_change?
    new_email = profile_params[:email_address]
    email_changed = new_email.present? &&
      User.normalize_value_for(:email_address, new_email) != Current.user.email_address

    profile_params[:password].present? || email_changed
  end
end
