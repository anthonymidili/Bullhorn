class CreateBrothers < ActiveRecord::Migration[6.0]
  def change
    create_table :brothers do |t|
      t.string :relation
      t.string :name
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
