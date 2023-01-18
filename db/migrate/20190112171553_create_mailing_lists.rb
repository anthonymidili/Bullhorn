class CreateMailingLists < ActiveRecord::Migration[5.2]
  def change
    create_view :mailing_lists
  end
end
