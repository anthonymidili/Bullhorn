class RemoveNameToAdditionalRecipient < ActiveRecord::Migration[6.0]
  def change
    drop_view :mailing_lists
    remove_column :additional_recipients, :first_name
    remove_column :additional_recipients, :last_name
  end
end
