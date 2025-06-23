class Users::Seller::DashboardPolicy < ApplicationPolicy
  def show?
    user.seller?
  end
end
