require "test_helper"

class HashtagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "hashtag_viewer@example.com", password: "password", username: "htviewer", confirmed_at: Time.current)
    @post = @user.posts.create!(body: "Hello from #community feed!")
  end

  test "unauthenticated user is redirected to sign in" do
    get hashtag_path(name: "community")
    assert_redirected_to new_user_session_path
  end

  test "authenticated user can view hashtag feed" do
    post user_session_path, params: { user: { email: @user.email, password: "password" } }

    get hashtag_path(name: "community")
    assert_response :success
    assert_includes @response.body, "#community"
    assert_includes @response.body, "Hello from"
  end

  test "search returns matching hashtags as JSON" do
    post user_session_path, params: { user: { email: @user.email, password: "password" } }

    get search_hashtags_path(term: "comm")
    assert_response :success

    json = JSON.parse(@response.body)
    assert json.is_a?(Array)
    assert_equal 1, json.size
    assert_equal "community", json.first["key"]
    assert_equal "#community", json.first["name"]
  end

  test "hashtag feed displays both posts and comments found" do
    post user_session_path, params: { user: { email: @user.email, password: "password" } }

    # Create another post and comment with #beer
    beer_post = @user.posts.create!(body: "Loving this craft #beer today!")
    beer_comment = @post.comments.create!(body: "Enjoy your cold #beer mate!", created_by: @user)

    get hashtag_path(name: "beer")
    assert_response :success
    assert_includes @response.body, "#beer"
    assert_includes @response.body, "Loving this craft"
    assert_includes @response.body, "Enjoy your cold"
    assert_includes @response.body, "Commented on"
    assert_includes @response.body, "1 post"
    assert_includes @response.body, "1 comment"
  end

  test "hashtag feed displays comments when hashtag is only in a comment" do
    post user_session_path, params: { user: { email: @user.email, password: "password" } }

    comment_only = @post.comments.create!(body: "Only in a comment #unique_tag", created_by: @user)

    get hashtag_path(name: "unique_tag")
    assert_response :success
    assert_includes @response.body, "Only in a comment"
    assert_includes @response.body, "Commented on"
    assert_includes @response.body, "0 posts"
    assert_includes @response.body, "1 comment"
  end

  test "hashtag feed shows empty state when hashtag has no posts or comments" do
    post user_session_path, params: { user: { email: @user.email, password: "password" } }

    get hashtag_path(name: "nonexistent_tag")
    assert_response :success
    assert_includes @response.body, "No posts or comments found for #nonexistent_tag."
  end

  test "infinite scroll on hashtags returns turbo stream with posts and comments" do
    post user_session_path, params: { user: { email: @user.email, password: "password" } }

    beer_post = @user.posts.create!(body: "Post with #scrolltag")
    beer_comment = @post.comments.create!(body: "Comment with #scrolltag", created_by: @user)

    get infinite_scroll_index_path(from_controller: "hashtags", from_action: "show", page: 0, id: "scrolltag", format: :turbo_stream)
    assert_response :success
    assert_includes @response.body, "Post with"
    assert_includes @response.body, "Comment with"
    assert_includes @response.body, "turbo-stream action=\"append\" target=\"posts\""
  end
end
