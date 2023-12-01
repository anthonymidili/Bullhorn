class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.references :direct, null: false, foreign_key: true
      t.references :created_by, null: false

      t.timestamps
    end
  end
end
