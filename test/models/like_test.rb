require "test_helper"

class LikeTest < ActiveSupport::TestCase
  test "like created successfully for a post" do
    user = User.create!(email: "liker@example.com", password: "password", username: "liker", confirmed_at: Time.current)
    post = user.posts.create!(body: "Test post for liking")

    other_user = User.create!(email: "other_liker@example.com", password: "password", username: "otherliker", confirmed_at: Time.current)
    like = other_user.likes.build(likeable: post)

    assert like.valid?
    assert like.save
    assert_equal post, like.likeable
  end

  test "validates uniqueness of like per user per likeable" do
    user = User.create!(email: "uniqueliker@example.com", password: "password", username: "uniqueliker", confirmed_at: Time.current)
    post = user.posts.create!(body: "Test post")
    other_user = User.create!(email: "liker2@example.com", password: "password", username: "liker2", confirmed_at: Time.current)

    first_like = other_user.likes.create!(likeable: post)
    assert first_like.persisted?

    duplicate_like = other_user.likes.build(likeable: post)
    assert_not duplicate_like.valid?
  end

  test "user.has_liked? returns correct like" do
    user = User.create!(email: "checker@example.com", password: "password", username: "checker", confirmed_at: Time.current)
    post = user.posts.create!(body: "Post to check")
    other_user = User.create!(email: "checker2@example.com", password: "password", username: "checker2", confirmed_at: Time.current)

    assert_nil other_user.has_liked?(post)

    other_user.likes.create!(likeable: post)
    assert_not_nil other_user.has_liked?(post)
  end
end
