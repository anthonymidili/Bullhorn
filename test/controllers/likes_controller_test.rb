require "test_helper"

class LikesControllerTest < ActionDispatch::IntegrationTest
  test "authenticated user can like a post" do
    user = User.create!(email: "liker_ctrl@example.com", password: "password", username: "likerctr1", confirmed_at: Time.current)
    post = user.posts.create!(body: "Post to like")

    other_user = User.create!(email: "likerctr2@example.com", password: "password", username: "likerctr2", confirmed_at: Time.current)
    post user_session_path, params: { user: { email: other_user.email, password: "password" } }

    assert_difference "Like.count", 1 do
      post likes_path, params: { like: { likeable_id: post.id, likeable_type: "Post" } }
    end
  end

  test "unauthenticated user cannot like a post" do
    user = User.create!(email: "noauth@example.com", password: "password", username: "noauth", confirmed_at: Time.current)
    post = user.posts.create!(body: "Post for unauth")

    assert_no_difference "Like.count" do
      post likes_path, params: { like: { likeable_id: post.id, likeable_type: "Post" } }
    end

    assert_redirected_to new_user_session_path
  end

  test "model validates uniqueness of like per user per likeable" do
    user = User.create!(email: "uniqueliker@example.com", password: "password", username: "uniqueliker", confirmed_at: Time.current)
    post = user.posts.create!(body: "Test post")
    other_user = User.create!(email: "liker2@example.com", password: "password", username: "liker2", confirmed_at: Time.current)

    first_like = other_user.likes.create!(likeable: post)
    assert first_like.persisted?

    duplicate_like = other_user.likes.build(likeable: post)
    assert_not duplicate_like.valid?
  end
end
