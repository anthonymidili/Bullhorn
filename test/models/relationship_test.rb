require "test_helper"

class RelationshipTest < ActiveSupport::TestCase
  test "relationship creates successfully between two users" do
    user1 = User.create!(email: "user1@example.com", password: "password", username: "user1", confirmed_at: Time.current)
    user2 = User.create!(email: "user2@example.com", password: "password", username: "user2", confirmed_at: Time.current)

    relationship = user1.relationships.build(followed: user2)
    assert relationship.valid?
    assert relationship.save
    assert_equal user2, relationship.followed
  end

  test "user following association works correctly" do
    user1 = User.create!(email: "user3@example.com", password: "password", username: "user3", confirmed_at: Time.current)
    user2 = User.create!(email: "user4@example.com", password: "password", username: "user4", confirmed_at: Time.current)

    user1.relationships.create!(followed: user2)

    assert user1.following.include?(user2)
    assert user2.followers.include?(user1)
  end
end
