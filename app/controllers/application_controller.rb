class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  include Authentication

  helper_method :admin?

  private

  def admin?
  resume_session
  Current.user&.admin? || false
end

  def require_admin
    redirect_to root_path, alert: "Недостатньо прав для цієї дії" unless admin?
  end
end
