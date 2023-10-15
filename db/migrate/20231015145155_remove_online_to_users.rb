class RemoveOnlineToUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :online
  end
end
