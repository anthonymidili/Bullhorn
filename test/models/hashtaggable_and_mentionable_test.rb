require "test_helper"

class HashtaggableAndMentionableTest < ActiveSupport::TestCase
  setup do
    @alice = User.create!(email: "alice@example.com", password: "password", username: "alice", confirmed_at: Time.current)
    @bob = User.create!(email: "bob@example.com", password: "password", username: "bob", confirmed_at: Time.current)
  end

  test "post extracts hashtags and creates association" do
    post = @alice.posts.create!(body: "Loving #rails and #ruby_on_rails!")
    assert_equal ["rails", "ruby_on_rails"].sort, post.extract_hashtag_names.sort
    assert_equal ["rails", "ruby_on_rails"].sort, post.hashtags.pluck(:name).map(&:downcase).sort
  end

  test "post extracts mentions and returns User records" do
    post = @alice.posts.create!(body: "Hey @bob and @nonexistent_user, check this out!")
    assert_equal ["bob", "nonexistent_user"].sort, post.extract_mentioned_usernames.sort
    assert_equal [@bob], post.mentioned_users.to_a
  end

  test "comment extracts hashtags and mentions" do
    post = @alice.posts.create!(body: "Initial post")
    comment = post.comments.create!(body: "Great post @alice! Check out #devops", created_by: @bob)

    assert_equal ["devops"], comment.extract_hashtag_names
    assert_equal ["alice"], comment.extract_mentioned_usernames
    assert_equal [@alice], comment.mentioned_users.to_a
    assert_equal ["devops"], comment.hashtags.pluck(:name).map(&:downcase)
  end

  test "sync_hashtags updates hashtags when post is edited" do
    post = @alice.posts.create!(body: "First version with #tag1")
    assert_equal ["tag1"], post.hashtags.pluck(:name).map(&:downcase)

    post.update!(body: "Second version with #tag2 and #tag3")
    assert_equal ["tag2", "tag3"].sort, post.hashtags.pluck(:name).map(&:downcase).sort
  end
end
