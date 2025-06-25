class BuyerMonthlySpend < ApplicationRecord
  self.primary_key = nil

  belongs_to :buyer, class_name: 'User', foreign_key: :buyer_id
  belongs_to :tag, optional: true
  belongs_to :category, optional: true
end
