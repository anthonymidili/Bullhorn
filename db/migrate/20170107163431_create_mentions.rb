class CreateMentions < ActiveRecord::Migration[5.0]
  def change
    create_table :mentions do |t|
      t.integer :user_id, null: false
      t.integer :micropost_id, null: false

      t.timestamps
    end
  end
end
