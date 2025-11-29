require "test_helper"

class RepostsControllerTest < ActionDispatch::IntegrationTest
  test "authenticated user can repost a post" do
    user = User.create!(email: "original_author@example.com", password: "password", username: "originalauthor", confirmed_at: Time.current)
    original_post = user.posts.create!(body: "Post to be reposted")

    reposter = User.create!(email: "reposter_ctrl@example.com", password: "password", username: "reposterctr", confirmed_at: Time.current)
    post user_session_path, params: { user: { email: reposter.email, password: "password" } }

    assert_difference "Repost.count", 1 do
      post reposts_path, params: { repost: { post_id: original_post.id } }
    end

    assert_equal original_post, Repost.last.reposted
    assert_equal reposter, Repost.last.user
  end

  test "unauthenticated user cannot repost" do
    user = User.create!(email: "original4@example.com", password: "password", username: "original4", confirmed_at: Time.current)
    post = user.posts.create!(body: "Post for unauth repost")

    assert_no_difference "Repost.count" do
      post reposts_path, params: { repost: { post_id: post.id } }
    end

    assert_redirected_to new_user_session_path
  end

  test "model creates repost successfully" do
    user = User.create!(email: "repost_mod@example.com", password: "password", username: "repostmod", confirmed_at: Time.current)
    original_post = user.posts.create!(body: "Post to repost")

    reposter = User.create!(email: "repost_mod2@example.com", password: "password", username: "repostmod2", confirmed_at: Time.current)
    repost_post = reposter.posts.create!
    repost = Repost.create!(post: repost_post, reposted: original_post, user: reposter)

    assert repost.persisted?
    assert_equal original_post, repost.reposted
    assert_equal reposter, repost.user
  end
end
