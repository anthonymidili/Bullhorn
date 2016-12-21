class CreateUploads < ActiveRecord::Migration[5.0]
  def change
    create_table :albums do |t|
      t.integer :user_id

      t.timestamps
    end

    create_table :photos do |t|
      t.integer :user_id
      t.integer :album_id
      t.string :image
      t.string :caption

      t.timestamps
    end
  end
end
