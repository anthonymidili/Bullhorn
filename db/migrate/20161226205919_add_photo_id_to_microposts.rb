class AddPhotoIdToMicroposts < ActiveRecord::Migration[5.0]
  def change
    add_column :microposts, :photo_id, :integer
  end
end
