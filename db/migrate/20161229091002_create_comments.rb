class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.text :content
      t.integer :commentable_id, null: false
      t.string :commentable_type, null: false
      t.integer :created_by_user_id

      t.timestamps
    end
  end
end
