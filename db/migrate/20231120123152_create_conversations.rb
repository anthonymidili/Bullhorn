class CreateConversations < ActiveRecord::Migration[7.0]
  def change
    create_table :conversations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :direct, null: false, foreign_key: true
      t.index [ :user_id, :direct_id ], unique: true

      t.timestamps
    end
  end
end
