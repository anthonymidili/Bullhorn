class RemoveAlbums < ActiveRecord::Migration[5.0]
  def up
    drop_table :albums
    remove_column :photos, :album_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
