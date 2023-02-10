class AddPublishedToNewsLetters < ActiveRecord::Migration[5.2]
  def change
    add_column :news_letters, :published, :boolean, default: false
  end
end
