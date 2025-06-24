class CreateReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :reviews do |t|
      t.text :content
      t.integer :asset_id
      t.integer :buyer_id
      t.integer :rate_star

      t.timestamps
    end
  end
end
