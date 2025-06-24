class AddCategoryToTags < ActiveRecord::Migration[7.2]
  def change
    add_reference :tags, :category, foreign_key: true
  end
end
