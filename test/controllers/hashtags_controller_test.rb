require "test_helper"

class HashtagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "hashtag_viewer@example.com", password: "password", username: "htviewer", confirmed_at: Time.current)
    @post = @user.posts.create!(body: "Hello from #community feed!")
  end

  test "unauthenticated user is redirected to sign in" do
    get hashtag_path(name: "community")
    assert_redirected_to new_user_session_path
  end

  test "authenticated user can view hashtag feed" do
    post user_session_path, params: { user: { email: @user.email, password: "password" } }

    get hashtag_path(name: "community")
    assert_response :success
    assert_includes @response.body, "#community"
    assert_includes @response.body, "Hello from"
  end

  test "search returns matching hashtags as JSON" do
    post user_session_path, params: { user: { email: @user.email, password: "password" } }

    get search_hashtags_path(term: "comm")
    assert_response :success

    json = JSON.parse(@response.body)
    assert json.is_a?(Array)
    assert_equal 1, json.size
    assert_equal "community", json.first["key"]
    assert_equal "#community", json.first["name"]
  end
end
