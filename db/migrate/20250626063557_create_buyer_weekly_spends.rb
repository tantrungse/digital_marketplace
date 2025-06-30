class CreateBuyerWeeklySpends < ActiveRecord::Migration[7.2]
  def change
    create_view :buyer_weekly_spends, materialized: true
  end
end
