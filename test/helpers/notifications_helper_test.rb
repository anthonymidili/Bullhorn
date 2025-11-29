require "test_helper"

class NotificationsHelperTest < ActionView::TestCase
  include NotificationsHelper

  def setup
    Rails.application.routes.default_url_options[:host] = "test.host"
  end

  test "path_to_notifiable returns post url for Post" do
    user = User.create!(email: "n1@example.com", password: "password", username: "n1", confirmed_at: Time.current)
    post = user.posts.create!(body: "Test post for helper")

    url = path_to_notifiable(post)
    assert_match /posts\/.+/, url
  end

  test "path_to_notifiable returns event url for Event" do
    user = User.create!(email: "n2@example.com", password: "password", username: "n2", confirmed_at: Time.current)
    event = Event.create!(user: user, name: "Test Event", description: "desc", start_date: Time.current + 1.day, end_date: Time.current + 2.days, timezone: Time.zone.name)

    url = path_to_notifiable(event)
    assert_match /events\/.+/, url
  end

  test "path_to_notifiable returns user url for Relationship" do
    user = User.create!(email: "n3@example.com", password: "password", username: "n3", confirmed_at: Time.current)
    followed = User.create!(email: "n4@example.com", password: "password", username: "n4", confirmed_at: Time.current)
    relationship = user.relationships.create!(followed: followed)

    url = path_to_notifiable(relationship)
    assert_match /users\/.+/, url
  end

  test "path_to_notifiable returns direct url for Message" do
    u1 = User.create!(email: "n5@example.com", password: "password", username: "n5", confirmed_at: Time.current)
    u2 = User.create!(email: "n6@example.com", password: "password", username: "n6", confirmed_at: Time.current)
    direct = Direct.new
    direct.users << u1
    direct.users << u2
    direct.save!
    message = direct.messages.create!(body: "Hi", created_by: u1)

    url = path_to_notifiable(message)
    assert_match /direct_messages\//, url
  end
end
