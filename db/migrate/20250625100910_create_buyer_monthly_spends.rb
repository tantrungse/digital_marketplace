class CreateBuyerMonthlySpends < ActiveRecord::Migration[7.2]
  def change
    create_view :buyer_monthly_spends
  end
end
