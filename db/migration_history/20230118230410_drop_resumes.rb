class DropResumes < ActiveRecord::Migration[7.0]
  def change
    drop_table :resumes, force: :cascade
  end
end
