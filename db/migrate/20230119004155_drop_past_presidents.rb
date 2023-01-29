class DropPastPresidents < ActiveRecord::Migration[7.0]
  def change
    drop_table :past_presidents, force: :cascade
  end
end
