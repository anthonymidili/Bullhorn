require "test_helper"

class CreateNotificationsServiceMentionsTest < ActiveSupport::TestCase
  setup do
    @author = User.create!(email: "author_mention@test.com", password: "password", username: "author_m", confirmed_at: Time.current)
    @mentioned = User.create!(email: "mentioned@test.com", password: "password", username: "mentioned_user", confirmed_at: Time.current)
    @follower = User.create!(email: "follower@test.com", password: "password", username: "follower_m", confirmed_at: Time.current)
    Relationship.create!(user: @follower, followed: @author)
  end

  test "creates mention notification when user is mentioned in a post" do
    post = @author.posts.create!(body: "Hello @mentioned_user and welcome!")

    assert_difference -> { @mentioned.notifications.count }, 1 do
      CreateNotificationsService.new(post)
    end

    notification = @mentioned.notifications.last
    assert_equal @author, notification.notifier
    assert_equal post, notification.notifiable
    assert_includes notification.action, "Mentioned you in a Post"
  end

  test "follower who is also mentioned gets mention notification instead of generic post notification" do
    Relationship.create!(user: @mentioned, followed: @author)
    post = @author.posts.create!(body: "Special shoutout to @mentioned_user!")

    assert_difference -> { @mentioned.notifications.count }, 1 do
      CreateNotificationsService.new(post)
    end

    notification = @mentioned.notifications.last
    assert_includes notification.action, "Mentioned you in a Post"
  end

  test "author mentioning themselves does not create self-notification" do
    post = @author.posts.create!(body: "Talking to myself @author_m")

    assert_no_difference -> { @author.notifications.count } do
      CreateNotificationsService.new(post)
    end
  end

  test "creates mention notification when user is mentioned in a comment" do
    post = @author.posts.create!(body: "Great post")
    comment = post.comments.create!(body: "Check this out @mentioned_user", created_by: @author)

    assert_difference -> { @mentioned.notifications.count }, 1 do
      CreateNotificationsService.new(comment)
    end

    notification = @mentioned.notifications.last
    assert_equal @author, notification.notifier
    assert_equal comment, notification.notifiable
    assert_includes notification.action, "Mentioned you in a Comment"
  end
end
