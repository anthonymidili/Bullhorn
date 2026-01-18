require "test_helper"

class PushSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email: "push_test@example.com",
      password: "password",
      username: "pushuser",
      confirmed_at: Time.current
    )

    # Sign in via Devise session
    post user_session_path, params: { user: { email: @user.email, password: "password" } }
  end

  test "should get vapid public key" do
    get vapid_public_key_push_subscriptions_url
    assert_response :success
    assert_not_nil JSON.parse(response.body)["public_key"]
  end

  test "should create subscription" do
    assert_difference("PushSubscription.count") do
      post push_subscriptions_url, params: {
        subscription: {
          endpoint: "https://fcm.googleapis.com/fcm/send/test123",
          keys: {
            p256dh: "test_p256dh_key",
            auth: "test_auth_key"
          }
        }
      }, as: :json
    end

    assert_response :success
    assert JSON.parse(response.body)["success"]
  end

  test "should destroy subscription" do
    subscription = PushSubscription.create!(
      user: @user,
      endpoint: "https://fcm.googleapis.com/fcm/send/test456",
      p256dh: "test_p256dh",
      auth: "test_auth"
    )

    assert_difference("PushSubscription.count", -1) do
      delete push_subscriptions_url, params: {
        endpoint: subscription.endpoint
      }, headers: { "CONTENT_TYPE" => "application/json" }, as: :json
    end

    assert_response :success
    assert JSON.parse(response.body)["success"]
  end
end
