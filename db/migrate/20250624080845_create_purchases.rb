class CreatePurchases < ActiveRecord::Migration[7.2]
  def change
    create_table :purchases do |t|
      t.decimal :price
      t.string :download_url
      t.integer :asset_id
      t.integer :order_id

      t.timestamps
    end
  end
end
