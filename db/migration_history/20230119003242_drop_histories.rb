class DropHistories < ActiveRecord::Migration[7.0]
  def change
    drop_table :histories, force: :cascade
  end
end
