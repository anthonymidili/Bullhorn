class AddStatusToBugReports < ActiveRecord::Migration[7.0]
  def change
    add_column :bug_reports, :status, :string, default: "new", null: false
  end
end
