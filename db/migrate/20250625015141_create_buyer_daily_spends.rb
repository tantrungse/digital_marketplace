class CreateBuyerDailySpends < ActiveRecord::Migration[7.2]
  def change
    create_view :buyer_daily_spends
  end
end
