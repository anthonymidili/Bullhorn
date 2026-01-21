require "test_helper"

class ReceiveMailTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password",
      username: "testuser",
      confirmed_at: Time.current
    )
    @receive_mail = @user.create_receive_mail
  end

  test "belongs to user" do
    assert_equal @user, @receive_mail.user
  end

  test "defaults all notification preferences to true" do
    assert @receive_mail.for_new_posts
    assert @receive_mail.for_new_events
    assert @receive_mail.for_new_comments
    assert @receive_mail.for_new_relationships
    assert @receive_mail.for_new_likes
    assert @receive_mail.for_new_messages
  end

  test "defaults send_after to 24 hours" do
    assert_equal 24, @receive_mail.send_after_amount
    assert_equal "hours", @receive_mail.send_after_unit
  end

  test "recent_mail_timed_out? returns true when no mail sent yet" do
    assert @receive_mail.recent_mail_timed_out?
  end

  test "recent_mail_timed_out? returns false when mail sent recently" do
    @receive_mail.update!(last_mail_received: 1.hour.ago)
    assert_not @receive_mail.recent_mail_timed_out?
  end

  test "recent_mail_timed_out? returns true when mail timeout period passed" do
    @receive_mail.update!(last_mail_received: 25.hours.ago)
    assert @receive_mail.recent_mail_timed_out?
  end

  test "recent_mail_timed_out? respects custom timeout settings" do
    @receive_mail.update!(
      send_after_amount: 30,
      send_after_unit: "minutes",
      last_mail_received: 20.minutes.ago
    )
    assert_not @receive_mail.recent_mail_timed_out?

    @receive_mail.update!(last_mail_received: 31.minutes.ago)
    assert @receive_mail.recent_mail_timed_out?
  end

  test "update_last_mail_received sets timestamp to current time" do
    travel_to Time.zone.parse("2026-01-20 12:00:00") do
      @receive_mail.update_last_mail_received
      assert_in_delta Time.current, @receive_mail.last_mail_received, 1.second
    end
  end

  test "destroyed when user is destroyed" do
    receive_mail_id = @receive_mail.id
    @user.destroy
    assert_nil ReceiveMail.find_by(id: receive_mail_id)
  end
end
