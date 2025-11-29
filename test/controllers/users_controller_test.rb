require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "authenticated user can view their own profile" do
    user = User.create!(email: "profile@example.com", password: "password", username: "profile", confirmed_at: Time.current)
    post user_session_path, params: { user: { email: user.email, password: "password" } }

    get user_path(user)

    assert_response :success
    assert_includes @response.body, user.username
  end

  test "authenticated user can edit their profile" do
    user = User.create!(email: "editor@example.com", password: "password", username: "editor", confirmed_at: Time.current)
    post user_session_path, params: { user: { email: user.email, password: "password" } }

    get edit_user_path(user)
    assert_response :success

    patch user_path(user), params: { user: { first_name: "John", last_name: "Doe" } }
    assert_redirected_to user_path(user)

    user.reload
    assert_equal "John", user.first_name
    assert_equal "Doe", user.last_name
  end

  test "user cannot edit another user's profile" do
    user1 = User.create!(email: "owner@example.com", password: "password", username: "owner", confirmed_at: Time.current)
    user2 = User.create!(email: "attacker@example.com", password: "password", username: "attacker", confirmed_at: Time.current)

    post user_session_path, params: { user: { email: user2.email, password: "password" } }

    patch user_path(user1), params: { user: { first_name: "Hacked" } }

    assert_response :found
    user1.reload
    assert_nil user1.first_name
  end

  test "unauthenticated user cannot access user profile" do
    user = User.create!(email: "protected@example.com", password: "password", username: "protected", confirmed_at: Time.current)

    get user_path(user)

    assert_redirected_to new_user_session_path
  end
end
