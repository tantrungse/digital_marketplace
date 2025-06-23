class Users::Seller::DashboardController < ApplicationController
  # before_action :authorize_user

  def show
    authorize Dashboard
  end

  # private

  # def authorize_user
  #   authorize :seller_dashboard
  # end
end
