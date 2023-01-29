class RenameTopicsToArticles < ActiveRecord::Migration[5.2]
  def change
    rename_table :topics, :articles
  end
end
