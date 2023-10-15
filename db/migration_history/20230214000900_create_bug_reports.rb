class CreateBugReports < ActiveRecord::Migration[7.0]
  def change
    create_table :bug_reports do |t|
      t.string :subject
      t.text :body
      t.references :user, foreign_key: true
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
