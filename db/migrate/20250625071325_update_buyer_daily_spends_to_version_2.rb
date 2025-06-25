class UpdateBuyerDailySpendsToVersion2 < ActiveRecord::Migration[7.2]
  def change
    update_view :buyer_daily_spends, version: 2, revert_to_version: 1
  end
end
