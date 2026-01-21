require "test_helper"

class ReceivePushTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password",
      username: "testuser",
      confirmed_at: Time.current
    )
    @receive_push = @user.create_receive_push
  end

  test "belongs to user" do
    assert_equal @user, @receive_push.user
  end

  test "defaults all notification preferences to true" do
    assert @receive_push.for_new_posts
    assert @receive_push.for_new_events
    assert @receive_push.for_new_comments
    assert @receive_push.for_new_relationships
    assert @receive_push.for_new_likes
    assert @receive_push.for_new_messages
  end

  test "defaults send_after to 0 minutes" do
    assert_equal 0, @receive_push.send_after_amount
    assert_equal "minutes", @receive_push.send_after_unit
  end

  test "recent_push_timed_out? returns true when no push sent yet" do
    assert @receive_push.recent_push_timed_out?
  end

  test "recent_push_timed_out? returns false when push sent recently within timeout" do
    @receive_push.update!(
      send_after_amount: 5,
      send_after_unit: "minutes",
      last_push_received: 3.minutes.ago
    )
    assert_not @receive_push.recent_push_timed_out?
  end

  test "recent_push_timed_out? returns true when push timeout period passed" do
    @receive_push.update!(
      send_after_amount: 5,
      send_after_unit: "minutes",
      last_push_received: 6.minutes.ago
    )
    assert @receive_push.recent_push_timed_out?
  end

  test "recent_push_timed_out? with 0 minutes always returns true for immediate notifications" do
    @receive_push.update!(
      send_after_amount: 0,
      send_after_unit: "minutes",
      last_push_received: 1.second.ago
    )
    assert @receive_push.recent_push_timed_out?
  end

  test "update_last_push_received sets timestamp to current time" do
    travel_to Time.zone.parse("2026-01-20 12:00:00") do
      @receive_push.update_last_push_received
      assert_in_delta Time.current, @receive_push.last_push_received, 1.second
    end
  end

  test "destroyed when user is destroyed" do
    receive_push_id = @receive_push.id
    @user.destroy
    assert_nil ReceivePush.find_by(id: receive_push_id)
  end
end
