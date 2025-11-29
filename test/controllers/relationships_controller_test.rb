require "test_helper"

class RelationshipsControllerTest < ActionDispatch::IntegrationTest
  test "authenticated user can follow another user" do
    user1 = User.create!(email: "follower@example.com", password: "password", username: "follower", confirmed_at: Time.current)
    user2 = User.create!(email: "followee@example.com", password: "password", username: "followee", confirmed_at: Time.current)

    post user_session_path, params: { user: { email: user1.email, password: "password" } }

    assert_difference "Relationship.count", 1 do
      post relationships_path, params: { relationship: { followed_id: user2.id } }
    end

    assert user1.following.include?(user2)
  end

  test "authenticated user can unfollow another user" do
    user1 = User.create!(email: "unfollower@example.com", password: "password", username: "unfollower", confirmed_at: Time.current)
    user2 = User.create!(email: "unfollowee@example.com", password: "password", username: "unfollowee", confirmed_at: Time.current)

    relationship = user1.relationships.create!(followed: user2)

    post user_session_path, params: { user: { email: user1.email, password: "password" } }

    assert_difference "Relationship.count", -1 do
      delete relationship_path(relationship)
    end

    assert_not user1.following.include?(user2)
  end

  test "unauthenticated user cannot create relationship" do
    user = User.create!(email: "unauth_follow@example.com", password: "password", username: "unauth_follow", confirmed_at: Time.current)

    assert_no_difference "Relationship.count" do
      post relationships_path, params: { relationship: { followed_id: user.id } }
    end

    assert_redirected_to new_user_session_path
  end
end
