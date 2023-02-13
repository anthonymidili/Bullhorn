class AddUsernameToUsers < ActiveRecord::Migration[7.0]
  enable_extension 'citext'
  def change
    add_column :users, :username, :citext, unique: true

    User.find_each.with_index do |user, index|
      user.username = "username_#{index}"
      user.save
    end

    change_column_null :users, :username, false
  end
end
