class Asset < ApplicationRecord
  belongs_to :seller, class_name: 'User'
  has_many :asset_tags
  has_many :tags, through: :asset_tags
  has_many :reviews
  has_one_attached :file
end
