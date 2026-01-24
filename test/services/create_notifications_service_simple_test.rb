require "test_helper"

class CreateNotificationsServiceSimpleTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "checks user online status via Redis for push notifications" do
    author = User.create!(email: "author@test.com", password: "password", username: "author", confirmed_at: Time.current)
    recipient = User.create!(email: "recipient@test.com", password: "password", username: "recipient", confirmed_at: Time.current)
    Relationship.create!(user: recipient, followed: author)

    # Set up for push sending
    receive_push = recipient.create_receive_push(for_new_posts: true)
    recipient.push_subscriptions.create!(endpoint: "https://example.com", p256dh: "key", auth: "auth")

    # Test 1: User offline should update push timestamp
    users_online = Kredis.unique_list "users_online"
    users_online.remove recipient.id

    assert_nil receive_push.last_push_received
    post = author.posts.create!(body: "Test post")
    CreateNotificationsService.new(post)
    receive_push.reload
    assert_not_nil receive_push.last_push_received, "Push timestamp should be set when user is offline"

    # Test 2: User online should not update push timestamp
    receive_push.update!(last_push_received: nil)
    users_online << recipient.id

    post2 = author.posts.create!(body: "Another post")
    CreateNotificationsService.new(post2)
    receive_push.reload
    assert_nil receive_push.last_push_received, "Push timestamp should remain nil when user is online"
  end

  test "respects push notification preferences" do
    author = User.create!(email: "author2@test.com", password: "password", username: "author2", confirmed_at: Time.current)
    recipient = User.create!(email: "recipient2@test.com", password: "password", username: "recipient2", confirmed_at: Time.current)
    Relationship.create!(user: recipient, followed: author)

    # Ensure user is offline
    users_online = Kredis.unique_list "users_online"
    users_online.remove recipient.id

    # Test 1: preference disabled should not send
    receive_push = recipient.create_receive_push(for_new_posts: false)
    recipient.push_subscriptions.create!(endpoint: "https://example.com", p256dh: "key", auth: "auth")

    post = author.posts.create!(body: "Test")
    CreateNotificationsService.new(post)
    receive_push.reload
    assert_nil receive_push.last_push_received, "Push should not send when preference is disabled"
  end

  test "sends push when preference is enabled" do
    author = User.create!(email: "author_enabled@test.com", password: "password", username: "author_enabled", confirmed_at: Time.current)
    recipient = User.create!(email: "recipient_enabled@test.com", password: "password", username: "recipient_enabled", confirmed_at: Time.current)
    Relationship.create!(user: recipient, followed: author)

    # Ensure user is offline
    users_online = Kredis.unique_list "users_online"
    users_online.remove recipient.id

    # Test 2: preference enabled should send
    receive_push = recipient.create_receive_push(for_new_posts: true)
    recipient.push_subscriptions.create!(endpoint: "https://example.com", p256dh: "key", auth: "auth")

    post = author.posts.create!(body: "Test 2")
    CreateNotificationsService.new(post)
    receive_push.reload
    assert_not_nil receive_push.last_push_received, "Push should send when preference is enabled"
  end

  test "respects push notification throttling" do
    author = User.create!(email: "author3@test.com", password: "password", username: "author3", confirmed_at: Time.current)
    recipient = User.create!(email: "recipient3@test.com", password: "password", username: "recipient3", confirmed_at: Time.current)
    Relationship.create!(user: recipient, followed: author)

    # Set up push with throttling (5 minutes)
    receive_push = recipient.create_receive_push(
      for_new_posts: true,
      send_after_amount: 5,
      send_after_unit: "minutes"
    )
    recipient.push_subscriptions.create!(endpoint: "https://example.com", p256dh: "key", auth: "auth")

    # Ensure user is offline
    users_online = Kredis.unique_list "users_online"
    users_online.remove recipient.id

    # First push should go through (no previous push)
    post1 = author.posts.create!(body: "Test 1")
    CreateNotificationsService.new(post1)
    receive_push.reload
    first_push_time = receive_push.last_push_received
    assert_not_nil first_push_time, "First push should set timestamp"

    # Second push within throttle window should NOT update timestamp
    post2 = author.posts.create!(body: "Test 2")
    CreateNotificationsService.new(post2)
    receive_push.reload
    assert_equal first_push_time.to_i, receive_push.last_push_received.to_i, "Push timestamp should not change within throttle window"
  end

  test "sends email fallback when push subscription expires" do
    author = User.create!(email: "author_expired@test.com", password: "password", username: "author_expired", confirmed_at: Time.current)
    recipient = User.create!(email: "recipient_expired@test.com", password: "password", username: "recipient_expired", confirmed_at: Time.current)
    Relationship.create!(user: recipient, followed: author)

    # Set up push preferences (user previously had push enabled)
    receive_push = recipient.create_receive_push(for_new_posts: true)
    receive_mail = recipient.create_receive_mail(for_new_posts: false) # Email disabled for posts

    # User is offline
    users_online = Kredis.unique_list "users_online"
    users_online.remove recipient.id

    # No active push subscriptions (expired)
    assert_equal 0, recipient.push_subscriptions.count

    # Should send email as fallback, honoring push preferences (not email preferences)
    post = author.posts.create!(body: "Test post")

    assert_enqueued_emails 1 do
      CreateNotificationsService.new(post)
    end

    # Email timestamp should be updated, not push timestamp
    receive_mail.reload
    assert_not_nil receive_mail.last_mail_received, "Email timestamp should be updated when push expired"
  end

  test "does not send email fallback for users who never had push" do
    author = User.create!(email: "author_never@test.com", password: "password", username: "author_never", confirmed_at: Time.current)
    recipient = User.create!(email: "recipient_never@test.com", password: "password", username: "recipient_never", confirmed_at: Time.current)
    Relationship.create!(user: recipient, followed: author)

    # No receive_push record (user never enabled push)
    receive_mail = recipient.create_receive_mail(for_new_posts: false) # Email disabled

    # User is offline
    users_online = Kredis.unique_list "users_online"
    users_online.remove recipient.id

    # Should NOT send email (user never had push, email is disabled)
    post = author.posts.create!(body: "Test post")

    assert_no_enqueued_emails do
      CreateNotificationsService.new(post)
    end
  end
end
