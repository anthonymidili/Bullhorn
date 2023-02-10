class DropJobListings < ActiveRecord::Migration[7.0]
  def change
    drop_table :job_listings, force: :cascade
    remove_column :receive_mails, :for_new_job_listings
  end
end
