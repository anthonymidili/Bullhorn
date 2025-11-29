require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "comment created successfully for a post" do
    user = User.create!(email: "commenter@example.com", password: "password", username: "commenter", confirmed_at: Time.current)
    post = user.posts.create!(body: "Post to comment on")

    comment = post.comments.build(body: "Great post!", created_by: user)
    assert comment.valid?
    assert comment.save
    assert_equal user, comment.created_by
    assert_equal post, comment.commentable
  end

  test "validates body presence" do
    user = User.create!(email: "commenter2@example.com", password: "password", username: "commenter2", confirmed_at: Time.current)
    post = user.posts.create!(body: "Another post")

    comment = post.comments.build(created_by: user)
    assert_not comment.valid?
    assert_includes comment.errors[:body], "can't be blank"
  end

  test "comment can be liked" do
    user = User.create!(email: "commenter3@example.com", password: "password", username: "commenter3", confirmed_at: Time.current)
    post = user.posts.create!(body: "Post for liking comments")
    comment = post.comments.create!(body: "Comment to like", created_by: user)

    other_user = User.create!(email: "commentliker@example.com", password: "password", username: "commentliker", confirmed_at: Time.current)
    like = other_user.likes.create!(likeable: comment)

    assert like.persisted?
    assert_equal 1, comment.likes.count
  end

  test "comments ordered by created_at descending by default" do
    user = User.create!(email: "commenter4@example.com", password: "password", username: "commenter4", confirmed_at: Time.current)
    post = user.posts.create!(body: "Post with multiple comments")

    comment1 = post.comments.create!(body: "First comment", created_by: user)
    sleep 0.01
    comment2 = post.comments.create!(body: "Second comment", created_by: user)

    assert_equal comment2, post.comments.first
    assert_equal comment1, post.comments.last
  end
end
