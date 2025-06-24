class CreateAssets < ActiveRecord::Migration[7.2]
  def change
    create_table :assets do |t|
      t.string :title
      t.text :description
      t.decimal :price
      t.string :status
      t.integer :tag_id
      t.integer :seller_id

      t.timestamps
    end
  end
end
