class CreateAssetCarts < ActiveRecord::Migration[7.2]
  def change
    create_table :asset_carts do |t|
      t.integer :cart_id
      t.integer :asset_id

      t.timestamps
    end
  end
end
