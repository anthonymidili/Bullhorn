class AddAvatarIdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :avatar_id, :integer
  end
end
