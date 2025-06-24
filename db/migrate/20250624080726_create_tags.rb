class CreateTags < ActiveRecord::Migration[7.2]
  def change
    create_table :tags do |t|
      t.string :name
      t.string :description
      t.integer :parent_tag_id

      t.timestamps
    end
  end
end
