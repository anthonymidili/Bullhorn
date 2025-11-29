require "test_helper"

class PostsControllerExtendedTest < ActionDispatch::IntegrationTest
  test "authenticated user can edit their post" do
    user = User.create!(email: "post_editor@example.com", password: "password", username: "posteditor", confirmed_at: Time.current)
    post = user.posts.create!(body: "Original content")

    post user_session_path, params: { user: { email: user.email, password: "password" } }

    patch post_path(post), params: { post: { body: "Updated content" } }

    post.reload
    assert post.body.to_s.include?("Updated content")
  end

  test "user can delete their own post" do
    user = User.create!(email: "post_deleter@example.com", password: "password", username: "postdeleter", confirmed_at: Time.current)
    post = user.posts.create!(body: "Post to delete")

    post user_session_path, params: { user: { email: user.email, password: "password" } }

    assert_difference "Post.count", -1 do
      delete post_path(post)
    end
  end

  test "user cannot delete another user's post" do
    user1 = User.create!(email: "post_owner@example.com", password: "password", username: "postowner", confirmed_at: Time.current)
    post = user1.posts.create!(body: "Post to protect")

    user2 = User.create!(email: "post_thief@example.com", password: "password", username: "postthief", confirmed_at: Time.current)
    post user_session_path, params: { user: { email: user2.email, password: "password" } }

    assert_no_difference "Post.count" do
      delete post_path(post)
    end
  end

  test "unauthenticated user cannot create post" do
    assert_no_difference "Post.count" do
      post posts_path, params: { post: { body: "Unauthorized post" } }
    end

    assert_redirected_to new_user_session_path
  end

  test "post with rich text body saves correctly" do
    user = User.create!(email: "rich_text_user@example.com", password: "password", username: "richtextuser", confirmed_at: Time.current)
    post user_session_path, params: { user: { email: user.email, password: "password" } }

    post posts_path, params: { post: { body: "Post with **bold** and _italic_ text" } }

    created_post = Post.last
    assert created_post.body.present?
  end

  test "posts are ordered by created_at descending" do
    user = User.create!(email: "order_user@example.com", password: "password", username: "orderuser", confirmed_at: Time.current)

    post1 = user.posts.create!(body: "First post", created_at: 2.hours.ago)
    _post2 = user.posts.create!(body: "Second post", created_at: 1.hour.ago)
    post3 = user.posts.create!(body: "Third post", created_at: Time.current)

    posts = Post.all
    assert_equal post3, posts.first
    assert_equal post1, posts.last
  end

  test "post.by_following returns posts from following users and self" do
    user = User.create!(email: "follower@example.com", password: "password", username: "follower", confirmed_at: Time.current)
    following1 = User.create!(email: "following1@example.com", password: "password", username: "following1", confirmed_at: Time.current)
    following2 = User.create!(email: "following2@example.com", password: "password", username: "following2", confirmed_at: Time.current)
    other = User.create!(email: "other@example.com", password: "password", username: "other", confirmed_at: Time.current)

    user.relationships.create!(followed: following1)
    user.relationships.create!(followed: following2)

    user_post = user.posts.create!(body: "My post")
    following1_post = following1.posts.create!(body: "Following post")
    following2_post = following2.posts.create!(body: "Another following post")
    other_post = other.posts.create!(body: "Other post")

    feed = Post.by_following(user)

    assert feed.exists?(user_post.id)
    assert feed.exists?(following1_post.id)
    assert feed.exists?(following2_post.id)
    assert_not feed.exists?(other_post.id)
  end
end
