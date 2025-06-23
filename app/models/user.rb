class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_and_belongs_to_many :roles

  def admin?
    roles.pluck(:name).include?("admin")
  end

  def buyer?
    roles.pluck(:name).include?("buyer")
  end

  def seller?
    roles.pluck(:name).include?("seller")
  end
end
