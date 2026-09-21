require "test_helper"

class HashtagTest < ActiveSupport::TestCase
  test "validates presence of name" do
    hashtag = Hashtag.new(name: "")
    assert_not hashtag.valid?
    assert_includes hashtag.errors[:name], "can't be blank"
  end

  test "strips leading hash symbol and normalizes" do
    hashtag = Hashtag.create!(name: "#RubyOnRails")
    assert_equal "RubyOnRails", hashtag.name
  end

  test "validates uniqueness of name case-insensitively" do
    Hashtag.create!(name: "Ruby")
    duplicate = Hashtag.new(name: "ruby")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "validates format of name" do
    invalid = Hashtag.new(name: "invalid tag!")
    assert_not invalid.valid?

    valid = Hashtag.new(name: "valid_tag_123")
    assert valid.valid?
  end

  test "associations with post and comment" do
    user = User.create!(email: "tag_user@example.com", password: "password", username: "taguser", confirmed_at: Time.current)
    post = user.posts.create!(body: "Check out #BullhornXL today!")
    hashtag = Hashtag.find_by("name ILIKE ?", "BullhornXL")

    assert_not_nil hashtag
    assert_includes post.hashtags, hashtag
    assert_includes hashtag.posts, post

    comment = post.comments.create!(body: "Replying about #BullhornXL", created_by: user)
    assert_includes comment.hashtags, hashtag
    assert_includes hashtag.comments, comment
  end

  test "search finds matching hashtags" do
    Hashtag.create!(name: "apple")
    Hashtag.create!(name: "application")
    Hashtag.create!(name: "banana")

    results = Hashtag.search("app")
    assert_equal 2, results.count
    assert_includes results.pluck(:name), "apple"
    assert_includes results.pluck(:name), "application"
  end
end
