class ProductPolicy < ApplicationPolicy
  def browse?
    user.buyer?
  end
end
