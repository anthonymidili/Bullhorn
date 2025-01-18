class MoveLastEmailNotificationReceivedToReceiveMails < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :last_email_notification_received,
    :datetime, precision: nil
    add_column :receive_mails, :last_mail_received,
    :datetime, precision: nil
  end
end
