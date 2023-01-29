class DropAdditionalRecipients < ActiveRecord::Migration[7.0]
  def change
    drop_table :additional_recipients, force: :cascade
  end
end
