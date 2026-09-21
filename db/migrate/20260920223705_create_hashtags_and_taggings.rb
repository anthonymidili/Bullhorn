class CreateHashtagsAndTaggings < ActiveRecord::Migration[8.1]
  def change
    create_table :hashtags do |t|
      t.citext :name, null: false
      t.timestamps
    end
    add_index :hashtags, :name, unique: true

    create_table :taggings do |t|
      t.references :hashtag, null: false, foreign_key: true
      t.references :taggable, polymorphic: true, null: false
      t.timestamps
    end
    add_index :taggings, [:hashtag_id, :taggable_type, :taggable_id], unique: true, name: "index_taggings_uniqueness"
  end
end
