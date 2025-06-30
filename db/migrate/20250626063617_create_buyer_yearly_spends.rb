class CreateBuyerYearlySpends < ActiveRecord::Migration[7.2]
  def change
    create_view :buyer_yearly_spends, materialized: true
  end
end
