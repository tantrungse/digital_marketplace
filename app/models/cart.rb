class Cart < ApplicationRecord
  belongs_to :buyer, class_name: 'User'
  has_many :asset_carts
  has_many :assets, through: :asset_carts
end
