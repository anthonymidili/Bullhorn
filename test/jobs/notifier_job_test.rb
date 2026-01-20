require "test_helper"

class NotifierJobTest < ActiveSupport::TestCase
  test "perform enqueues CreateNotificationsService" do
    user = User.create!(email: "jobuser@example.com", password: "password", username: "jobuser", confirmed_at: Time.current)
    post = user.posts.create!(body: "Job test post")

    called = nil

    # Use dependency injection: pass a fake notifier class that captures the argument
    fake = Class.new do
      define_method(:initialize) do |arg|
        called = arg
      end
    end

    NotifierJob.perform_now(post, fake)

    assert_equal post, called
  end
end
