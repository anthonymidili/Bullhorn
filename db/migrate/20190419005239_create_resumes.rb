class CreateResumes < ActiveRecord::Migration[5.2]
  def change
    create_table :resumes do |t|
      t.string :title
      t.string :classification
      t.string :status
      t.boolean :is_listed, default: true
      t.references :user, null: false

      t.timestamps
    end
  end
end
