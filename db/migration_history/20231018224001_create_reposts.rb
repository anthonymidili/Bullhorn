class CreateReposts < ActiveRecord::Migration[7.0]
  def change
    create_table :reposts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.bigint :reposted_id, null: false, foreign_key: true
      t.index [ :post_id, :reposted_id ], unique: true
      t.index :reposted_id
      
      t.timestamps
    end
  end
end
