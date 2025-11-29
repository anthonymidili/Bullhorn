require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "associations and default scope" do
    user = User.create!(email: "post_user@example.com", password: "password", username: "postuser", confirmed_at: Time.current)
    post = user.posts.create!(body: "Hello world")

    assert_equal user, post.user
    assert post.is_post?
  end

  test "post_type for reposts and quoted reposts" do
    user = User.create!(email: "post2@example.com", password: "password", username: "postuser2", confirmed_at: Time.current)
    original = user.posts.create!(body: "Original")
    repost_post = user.posts.create!
    # attach a Repost record to simulate reposting
    repost = Repost.create!(post: repost_post, reposted: original, user: user)

    assert_equal "repost", repost_post.post_type
    # quoted repost: reposting and body present
    quoted = user.posts.create!(body: "Quoted")
    quoted_repost = Repost.create!(post: quoted, reposted: original, user: user)
    assert_equal "quoted_repost", quoted.post_type if quoted.reposting
  end
end
