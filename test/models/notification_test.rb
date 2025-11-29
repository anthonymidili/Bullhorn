require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "notification creates for recipient and notifier" do
    user1 = User.create!(email: "notifier@example.com", password: "password", username: "notifier", confirmed_at: Time.current)
    user2 = User.create!(email: "recipient@example.com", password: "password", username: "recipient", confirmed_at: Time.current)
    post = user1.posts.create!(body: "Notification test post")

    notification = Notification.create!(recipient: user2, notifier: user1, notifiable: post, is_read: false)

    assert notification.persisted?
    assert_equal user2, notification.recipient
    assert_equal user1, notification.notifier
    assert_equal post, notification.notifiable
    assert_equal false, notification.is_read
  end

  test "by_unread scope returns only unread notifications" do
    user1 = User.create!(email: "notif1@example.com", password: "password", username: "notif1", confirmed_at: Time.current)
    user2 = User.create!(email: "notif2@example.com", password: "password", username: "notif2", confirmed_at: Time.current)
    post = user1.posts.create!(body: "Test")

    Notification.create!(recipient: user2, notifier: user1, notifiable: post, is_read: false)
    Notification.create!(recipient: user2, notifier: user1, notifiable: post, is_read: true)

    unread = Notification.by_unread
    assert_equal 1, unread.count
    assert_equal false, unread.first.is_read
  end

  test "by_type scope filters by notifiable type" do
    user1 = User.create!(email: "type1@example.com", password: "password", username: "type1", confirmed_at: Time.current)
    user2 = User.create!(email: "type2@example.com", password: "password", username: "type2", confirmed_at: Time.current)
    post = user1.posts.create!(body: "Test")

    Notification.create!(recipient: user2, notifier: user1, notifiable: post)
    Notification.create!(recipient: user2, notifier: user1, notifiable: user1.relationships.create!(followed: user2))

    post_notifications = Notification.by_type("Post")
    assert_equal 1, post_notifications.count
  end

  test "recent_unread_count returns unread from last week" do
    user1 = User.create!(email: "recent1@example.com", password: "password", username: "recent1", confirmed_at: Time.current)
    user2 = User.create!(email: "recent2@example.com", password: "password", username: "recent2", confirmed_at: Time.current)
    post = user1.posts.create!(body: "Test")

    Notification.create!(recipient: user2, notifier: user1, notifiable: post, is_read: false, created_at: Time.current)
    Notification.create!(recipient: user2, notifier: user1, notifiable: post, is_read: true, created_at: 2.weeks.ago)

    assert_equal 1, Notification.recent_unread_count
  end

  test "bell_message_types includes expected notification types" do
    types = Notification.bell_message_types
    assert types.include?("Post")
    assert types.include?("Comment")
    assert types.include?("Like")
    assert types.include?("Relationship")
  end

  test "default scope orders by created_at descending" do
    user1 = User.create!(email: "order1@example.com", password: "password", username: "order1", confirmed_at: Time.current)
    user2 = User.create!(email: "order2@example.com", password: "password", username: "order2", confirmed_at: Time.current)
    post = user1.posts.create!(body: "Test")

    notif1 = Notification.create!(recipient: user2, notifier: user1, notifiable: post, created_at: 2.hours.ago)
    notif2 = Notification.create!(recipient: user2, notifier: user1, notifiable: post, created_at: Time.current)

    assert_equal notif2, Notification.first
    assert_equal notif1, Notification.last
  end
end
