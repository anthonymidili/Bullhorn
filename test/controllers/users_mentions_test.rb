require "test_helper"

class UsersMentionsTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "main_user@example.com", password: "password", username: "mainuser", confirmed_at: Time.current)
    @alice = User.create!(email: "alice_wonder@example.com", password: "password", username: "alicew", first_name: "Alice", last_name: "Wonder", confirmed_at: Time.current)
  end

  test "mentions endpoint returns matching users as JSON" do
    post user_session_path, params: { user: { email: @user.email, password: "password" } }

    get mentions_users_path(term: "ali")
    assert_response :success

    json = JSON.parse(@response.body)
    assert json.is_a?(Array)
    match = json.find { |u| u["key"] == "alicew" }
    assert_not_nil match
    assert_equal "alicew", match["value"]
    assert_equal "Alice Wonder", match["name"]
    assert match["avatar_url"].present?
  end

  test "user profile can be accessed via @username route" do
    post user_session_path, params: { user: { email: @user.email, password: "password" } }

    get "/@alicew"
    assert_response :success
    assert_includes @response.body, "alicew"
  end
end
