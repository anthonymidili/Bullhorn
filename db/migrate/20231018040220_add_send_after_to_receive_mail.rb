class AddSendAfterToReceiveMail < ActiveRecord::Migration[7.0]
  def change
    add_column :receive_mails, :send_after_amount, :integer, default: 24
    add_column :receive_mails, :send_after_unit, :string, default: "hours"
  end
end
