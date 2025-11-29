require "test_helper"

class ProfileTest < ActiveSupport::TestCase
  test "profile belongs to user" do
    user = User.create!(email: "profile_user@example.com", password: "password", username: "profileuser", confirmed_at: Time.current)
    profile = user.build_profile(workplace: "Tech Company", position: "Developer")
    profile.save

    assert_equal user, profile.user
  end

  test "occupation combines workplace and position" do
    user = User.create!(email: "occupation@example.com", password: "password", username: "occupationuser", confirmed_at: Time.current)
    profile = user.build_profile(workplace: "Acme Corp", position: "Senior Developer")
    profile.save

    assert_equal "Acme Corp - Senior Developer", profile.occupation
  end

  test "occupation returns only workplace if position is blank" do
    user = User.create!(email: "work_only@example.com", password: "password", username: "workonly", confirmed_at: Time.current)
    profile = user.build_profile(workplace: "Tech Inc", position: nil)
    profile.save

    assert_equal "Tech Inc", profile.occupation
  end

  test "occupation returns only position if workplace is blank" do
    user = User.create!(email: "pos_only@example.com", password: "password", username: "posonly", confirmed_at: Time.current)
    profile = user.build_profile(workplace: nil, position: "Manager")
    profile.save

    assert_equal "Manager", profile.occupation
  end

  test "occupation returns empty string if both workplace and position are blank" do
    user = User.create!(email: "both_blank@example.com", password: "password", username: "bothblank", confirmed_at: Time.current)
    profile = user.build_profile(workplace: nil, position: nil)
    profile.save

    assert_equal "", profile.occupation
  end
end
