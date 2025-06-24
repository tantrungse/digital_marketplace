class Review < ApplicationRecord
  belongs_to :asset
  belongs_to :buyer, class_name: 'User'
end
