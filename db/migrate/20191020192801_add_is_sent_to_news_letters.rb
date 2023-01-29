class AddIsSentToNewsLetters < ActiveRecord::Migration[6.0]
  def change
    add_column :news_letters, :is_sent, :boolean, default: false
  end
end
