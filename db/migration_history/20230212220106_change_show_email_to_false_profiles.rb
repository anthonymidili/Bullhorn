class ChangeShowEmailToFalseProfiles < ActiveRecord::Migration[7.0]
  def change
    change_column :profiles, :show_email, :boolean, default: false
  end
end
