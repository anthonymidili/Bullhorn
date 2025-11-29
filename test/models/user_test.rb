require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "validates username presence and uniqueness" do
    _user = User.create!(email: "test1@example.com", password: "password", username: "tester", confirmed_at: Time.current)

    duplicate = User.new(email: "test2@example.com", password: "password", username: "tester")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:username], "has already been taken"
  end

  test "full_name returns combined first and last name" do
    user = User.new(first_name: "Jane", last_name: "Doe")
    assert_equal "Jane Doe", user.full_name

    user2 = User.new
    assert_nil user2.full_name
  end
end
