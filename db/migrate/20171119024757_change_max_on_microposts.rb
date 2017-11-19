class ChangeMaxOnMicroposts < ActiveRecord::Migration[5.1]
  def change
    change_column :microposts, :content, :text
  end
end
