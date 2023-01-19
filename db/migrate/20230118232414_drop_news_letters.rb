class DropNewsLetters < ActiveRecord::Migration[7.0]
  def change
    drop_table :news_letters, force: :cascade
    drop_table :articles, force: :cascade
  end
end
