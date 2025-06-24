class Tag < ApplicationRecord
  belongs_to :category
  has_many :asset_tags
  has_many :assets, through: :asset_tags
  belongs_to :parent, class_name: 'Tag', optional: true
end
