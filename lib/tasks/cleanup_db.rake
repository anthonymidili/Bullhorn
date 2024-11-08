desc "Clean old notifications and unconfirmed users"
task cleanup_db: :environment do
  puts "####################################################################"
  puts ">>>> Start Cleanup DB <<<<"
  puts "--------------------------------------------------------------------"
  puts "Cleaning old Notifications.........................................."
  notifications = Notification.by_older_than_month
  notifications.destroy_all
  puts "#{notifications.count} old Notifications have been removed."
  puts "--------------------------------------------------------------------"
  puts "Cleaning unconfirmed Users.........................................."
  users = User.by_unconfirmed.by_confirm_sent_after_hour
  users.destroy_all
  puts "#{users.count} unconfirmed Users have been removed."
  puts "--------------------------------------------------------------------"
  puts ">>>> Cleanup DB complete <<<<"
  puts "####################################################################"
end
