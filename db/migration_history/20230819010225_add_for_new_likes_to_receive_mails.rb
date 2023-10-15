class AddForNewLikesToReceiveMails < ActiveRecord::Migration[7.0]
  def change
    add_column :receive_mails, :for_new_likes, :boolean, default: true
  end
end
