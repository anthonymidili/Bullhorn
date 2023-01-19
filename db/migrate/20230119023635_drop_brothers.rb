class DropBrothers < ActiveRecord::Migration[7.0]
  def change
    drop_table :brothers, force: :cascade
  end
end
