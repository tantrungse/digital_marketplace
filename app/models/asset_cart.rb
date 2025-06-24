class AssetCart < ApplicationRecord
  belongs_to :cart
  belongs_to :asset
end
