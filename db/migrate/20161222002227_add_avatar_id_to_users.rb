class AddAvatarIdToUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :avatar_users do |t|
      t.integer :user_id
      t.integer :photo_id
    end
  end
end
