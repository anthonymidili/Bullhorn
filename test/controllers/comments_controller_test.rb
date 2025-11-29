require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  test "authenticated user can create comment on post" do
    user = User.create!(email: "comment_creator@example.com", password: "password", username: "commentcreator", confirmed_at: Time.current)
    post = user.posts.create!(body: "Post for commenting")

    other_user = User.create!(email: "commenter@example.com", password: "password", username: "commenter", confirmed_at: Time.current)
    post user_session_path, params: { user: { email: other_user.email, password: "password" } }

    assert_difference "Comment.count", 1 do
      post post_comments_path(post), params: { comment: { body: "Great post!" } }
    end

    assert_equal other_user, Comment.last.created_by
  end

  test "authenticated user can edit their own comment" do
    user = User.create!(email: "edit_user@example.com", password: "password", username: "edituser", confirmed_at: Time.current)
    post = user.posts.create!(body: "Post for editing comments")
    comment = post.comments.create!(body: "Original comment", created_by: user)

    post user_session_path, params: { user: { email: user.email, password: "password" } }

    patch post_comment_path(post, comment), params: { comment: { body: "Edited comment" } }

    comment.reload
    assert_equal "Edited comment", comment.body
  end

  test "user cannot edit another user's comment" do
    user1 = User.create!(email: "author@example.com", password: "password", username: "author", confirmed_at: Time.current)
    post = user1.posts.create!(body: "Post")
    comment = post.comments.create!(body: "Author's comment", created_by: user1)

    user2 = User.create!(email: "attacker@example.com", password: "password", username: "attacker", confirmed_at: Time.current)
    post user_session_path, params: { user: { email: user2.email, password: "password" } }

    patch post_comment_path(post, comment), params: { comment: { body: "Hacked comment" } }

    comment.reload
    assert_equal "Author's comment", comment.body
  end

  test "authenticated user can delete their own comment" do
    user = User.create!(email: "deleter@example.com", password: "password", username: "deleter", confirmed_at: Time.current)
    post = user.posts.create!(body: "Post with comment to delete")
    comment = post.comments.create!(body: "Comment to delete", created_by: user)

    post user_session_path, params: { user: { email: user.email, password: "password" } }

    assert_difference "Comment.count", -1 do
      delete post_comment_path(post, comment)
    end
  end

  test "unauthenticated user cannot create comment" do
    user = User.create!(email: "post_owner@example.com", password: "password", username: "postowner", confirmed_at: Time.current)
    post = user.posts.create!(body: "Post for unauth comment")

    assert_no_difference "Comment.count" do
      post post_comments_path(post), params: { comment: { body: "Unauthorized" } }
    end

    assert_redirected_to new_user_session_path
  end

  test "comment requires body" do
    user = User.create!(email: "validator@example.com", password: "password", username: "validator", confirmed_at: Time.current)
    post = user.posts.create!(body: "Post for validation")

    post user_session_path, params: { user: { email: user.email, password: "password" } }

    assert_no_difference "Comment.count" do
      post post_comments_path(post), params: { comment: { body: "" } }
    end
  end
end
