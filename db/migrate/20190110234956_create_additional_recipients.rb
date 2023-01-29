class CreateAdditionalRecipients < ActiveRecord::Migration[5.2]
  def change
    create_table :additional_recipients do |t|
      t.string :email
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
