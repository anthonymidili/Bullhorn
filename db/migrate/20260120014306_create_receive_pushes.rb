class CreateReceivePushes < ActiveRecord::Migration[8.1]
  def change
    create_table :receive_pushes do |t|
      t.boolean :for_new_comments, default: true, null: false
      t.boolean :for_new_events, default: true, null: false
      t.boolean :for_new_likes, default: true, null: false
      t.boolean :for_new_messages, default: true, null: false
      t.boolean :for_new_posts, default: true, null: false
      t.boolean :for_new_relationships, default: true, null: false
      t.datetime :last_push_received, precision: nil
      t.integer :send_after_amount, default: 0, null: false
      t.string :send_after_unit, default: "minutes", null: false
      t.references :user, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
