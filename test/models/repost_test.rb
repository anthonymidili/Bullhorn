require "test_helper"

class RepostTest < ActiveSupport::TestCase
  test "repost creates successfully" do
    user = User.create!(email: "reposter@example.com", password: "password", username: "reposter", confirmed_at: Time.current)
    original_post = user.posts.create!(body: "Original post")

    reposter_user = User.create!(email: "reposter2@example.com", password: "password", username: "reposter2", confirmed_at: Time.current)
    repost_post = reposter_user.posts.create!
    repost = Repost.create!(post: repost_post, reposted: original_post, user: reposter_user)

    assert repost.persisted?
    assert_equal repost_post, repost.post
    assert_equal original_post, repost.reposted
    assert_equal reposter_user, repost.user
  end

  test "repost has associations to user and posts" do
    user = User.create!(email: "user_repost@example.com", password: "password", username: "userrepost", confirmed_at: Time.current)
    original = user.posts.create!(body: "To be reposted")

    reposter = User.create!(email: "reposter3@example.com", password: "password", username: "reposter3", confirmed_at: Time.current)
    repost_post = reposter.posts.create!
    repost = Repost.create!(post: repost_post, reposted: original, user: reposter)

    assert_equal reposter, repost.user
    assert_equal repost_post, repost.post
    assert_equal original, repost.reposted
  end

  test "post tracks users who reposted it" do
    user = User.create!(email: "originator@example.com", password: "password", username: "originator", confirmed_at: Time.current)
    original = user.posts.create!(body: "Post to be reposted")

    reposter1 = User.create!(email: "r1@example.com", password: "password", username: "r1", confirmed_at: Time.current)
    repost1_post = reposter1.posts.create!
    Repost.create!(post: repost1_post, reposted: original, user: reposter1)

    reposter2 = User.create!(email: "r2@example.com", password: "password", username: "r2", confirmed_at: Time.current)
    repost2_post = reposter2.posts.create!
    Repost.create!(post: repost2_post, reposted: original, user: reposter2)

    reposting_users = original.users_who_reposted
    assert_equal 2, reposting_users.count
    assert reposting_users.include?(reposter1)
    assert reposting_users.include?(reposter2)
  end
end
