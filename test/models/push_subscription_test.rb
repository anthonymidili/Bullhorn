require "test_helper"

class PushSubscriptionTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "test_push@example.com",
      password: "password123",
      username: "pushtest",
      confirmed_at: Time.current
    )
    @subscription = PushSubscription.new(
      user: @user,
      endpoint: "https://fcm.googleapis.com/fcm/send/test123",
      p256dh: "test_p256dh_key",
      auth: "test_auth_key"
    )
  end

  test "should be valid with all required attributes" do
    assert @subscription.valid?
  end

  test "should belong to user" do
    assert_respond_to @subscription, :user
    assert_equal @user, @subscription.user
  end

  test "should require endpoint" do
    @subscription.endpoint = nil
    assert_not @subscription.valid?
    assert_includes @subscription.errors[:endpoint], "can't be blank"
  end

  test "should require p256dh" do
    @subscription.p256dh = nil
    assert_not @subscription.valid?
    assert_includes @subscription.errors[:p256dh], "can't be blank"
  end

  test "should require auth" do
    @subscription.auth = nil
    assert_not @subscription.valid?
    assert_includes @subscription.errors[:auth], "can't be blank"
  end

  test "should validate uniqueness of endpoint per user" do
    @subscription.save!

    duplicate = PushSubscription.new(
      user: @user,
      endpoint: @subscription.endpoint,
      p256dh: "different_key",
      auth: "different_auth"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:endpoint], "has already been taken"
  end

  test "should allow same endpoint for different users" do
    @subscription.save!

    different_user = User.create!(
      email: "test_push2@example.com",
      password: "password123",
      username: "pushtest2",
      confirmed_at: Time.current
    )
    different_user_subscription = PushSubscription.new(
      user: different_user,
      endpoint: @subscription.endpoint,
      p256dh: "different_key",
      auth: "different_auth"
    )

    assert different_user_subscription.valid?
  end
end
