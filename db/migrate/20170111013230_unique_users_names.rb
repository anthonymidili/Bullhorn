class UniqueUsersNames < ActiveRecord::Migration[5.0]
  def change
    enable_extension('citext')

    change_column :users, :name, :citext, null: false
    change_column :users, :email, :string, null: false

    add_index :users, :name, unique: true
  end
end
