module Admin
  class BaseController < ApplicationController
    before_action :require_admin_access

    private

    def require_admin_access
      redirect_to root_path, alert: "Доступ заборонено" unless admin?
    end
  end
end
