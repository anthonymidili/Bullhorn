class AddLastEmailNotificationReceivedToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :last_email_notification_received, 
    :datetime, precision: nil
  end
end
