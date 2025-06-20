class UpdateUsersTable < ActiveRecord::Migration[7.2]
  def change
    rename_column :users, :name, :first_name
    add_column :users, :last_name, :string
    change_column_null :users, :first_name, false
  end
end
