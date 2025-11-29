require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "create post requires authentication and creates post" do
    user = User.create!(email: "ctrl_user@example.com", password: "password", username: "ctrluser", confirmed_at: Time.current)

    # Sign in via Devise session to ensure mapping is present in Integration tests
    post user_session_path, params: { user: { email: user.email, password: "password" } }

    assert_response :redirect

    assert_difference "Post.count", 1 do
      post posts_url, params: { post: { body: "Integration test post" } }
    end

    assert_redirected_to root_url(anchor: "post_#{Post.last.id}")
  end
end
