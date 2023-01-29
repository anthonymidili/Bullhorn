desc "Clean old notifications"
task clean_notifications: :environment do
  puts "Cleaning notifications..."
  Notification.where('created_at < :time', time: (DateTime.current - 1.month)).delete_all
  puts "done."
end
