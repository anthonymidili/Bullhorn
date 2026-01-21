require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "notifications@example.com",
      password: "password",
      username: "notifyuser",
      confirmed_at: Time.current
    )
  end

  test "should get edit" do
    sign_in @user
    get edit_notifications_url
    assert_response :success
  end

  test "edit creates receive_mail if it doesn't exist" do
    sign_in @user
    assert_nil @user.receive_mail
    get edit_notifications_url
    @user.reload
    assert_not_nil @user.receive_mail
  end

  test "edit creates receive_push if it doesn't exist" do
    sign_in @user
    assert_nil @user.receive_push
    get edit_notifications_url
    @user.reload
    assert_not_nil @user.receive_push
  end

  test "should update receive_mail settings" do
    sign_in @user
    @user.create_receive_mail

    patch notifications_url, params: {
      receive_mail: {
        for_new_posts: "0",
        for_new_events: "1",
        for_new_comments: "1",
        for_new_relationships: "0",
        for_new_likes: "1",
        for_new_messages: "1",
        send_after_amount: "12",
        send_after_unit: "hours"
      }
    }

    assert_redirected_to edit_notifications_path
    assert_match(/Email notification settings/, flash[:notice])

    @user.reload
    assert_not @user.receive_mail.for_new_posts
    assert @user.receive_mail.for_new_events
    assert_not @user.receive_mail.for_new_relationships
    assert_equal 12, @user.receive_mail.send_after_amount
    assert_equal "hours", @user.receive_mail.send_after_unit
  end

  test "should update receive_push settings" do
    sign_in @user
    @user.create_receive_push

    patch notifications_url, params: {
      receive_push: {
        for_new_posts: "1",
        for_new_events: "0",
        for_new_comments: "1",
        for_new_relationships: "1",
        for_new_likes: "0",
        for_new_messages: "1",
        send_after_amount: "5",
        send_after_unit: "minutes"
      }
    }

    assert_redirected_to edit_notifications_path
    assert_match(/Push notification settings/, flash[:notice])

    @user.reload
    assert @user.receive_push.for_new_posts
    assert_not @user.receive_push.for_new_events
    assert_not @user.receive_push.for_new_likes
    assert_equal 5, @user.receive_push.send_after_amount
    assert_equal "minutes", @user.receive_push.send_after_unit
  end

  test "redirects to edit when no params provided" do
    sign_in @user

    patch notifications_url, params: {}

    assert_redirected_to edit_notifications_path
    assert_match(/No settings to update/, flash[:alert])
  end

  test "requires authentication" do
    get edit_notifications_url
    assert_redirected_to new_user_session_path

    patch notifications_url, params: { receive_mail: { for_new_posts: "0" } }
    assert_redirected_to new_user_session_path
  end
end
