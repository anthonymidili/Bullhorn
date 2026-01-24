namespace :notifications do
  desc "Expire push subscriptions for a user (for testing email fallback)"
  task :expire_push, [ :email ] => :environment do |t, args|
    unless args.email
      puts "Usage: rails notifications:expire_push[user@example.com]"
      exit 1
    end

    user = User.find_by(email: args.email)
    unless user
      puts "User not found: #{args.email}"
      exit 1
    end

    unless user.receive_push
      puts "User #{user.email} doesn't have push notifications enabled"
      exit 1
    end

    count = user.push_subscriptions.count
    user.push_subscriptions.destroy_all

    puts "✓ Expired #{count} push subscription(s) for #{user.email}"
    puts "  User still has receive_push record: #{user.receive_push.present?}"
    puts "  Push subscriptions remaining: #{user.push_subscriptions.count}"
    puts ""
    puts "Next notification will be sent via email fallback (when user is offline)"
  end

  desc "Show notification status for a user"
  task :status, [ :email ] => :environment do |t, args|
    unless args.email
      puts "Usage: rails notifications:status[user@example.com]"
      exit 1
    end

    user = User.find_by(email: args.email)
    unless user
      puts "User not found: #{args.email}"
      exit 1
    end

    puts "Notification Status for #{user.email}"
    puts "=" * 50
    puts "Online: #{user.online?}"
    puts ""
    puts "Push Notifications:"
    puts "  Enabled: #{user.receive_push.present?}"
    if user.receive_push
      puts "  Active subscriptions: #{user.push_subscriptions.count}"
      puts "  For new posts: #{user.receive_push.for_new_posts}"
      puts "  For new comments: #{user.receive_push.for_new_comments}"
      puts "  For new likes: #{user.receive_push.for_new_likes}"
      puts "  For new messages: #{user.receive_push.for_new_messages}"
      puts "  Has expired: #{user.receive_push.present? && user.push_subscriptions.none?}"
    end
    puts ""
    puts "Email Notifications:"
    puts "  Enabled: #{user.receive_mail.present?}"
    if user.receive_mail
      puts "  For new posts: #{user.receive_mail.for_new_posts}"
      puts "  For new comments: #{user.receive_mail.for_new_comments}"
      puts "  For new likes: #{user.receive_mail.for_new_likes}"
      puts "  For new messages: #{user.receive_mail.for_new_messages}"
    end
  end
end
