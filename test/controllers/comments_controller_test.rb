require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  test "authenticated user can create comment on post" do
    user = User.create!(email: "comment_creator@example.com", password: "password", username: "commentcreator", confirmed_at: Time.current)
    post = user.posts.create!(body: "Post for commenting")

    other_user = User.create!(email: "commenter@example.com", password: "password", username: "commenter", confirmed_at: Time.current)
    post user_session_path, params: { user: { email: other_user.email, password: "password" } }

    assert_difference "Comment.count", 1 do
      post post_comments_path(post), params: { comment: { body: "Great post!" } }
    end

    assert_equal other_user, Comment.last.created_by
  end

  test "authenticated user can edit their own comment" do
    user = User.create!(email: "edit_user@example.com", password: "password", username: "edituser", confirmed_at: Time.current)
    post = user.posts.create!(body: "Post for editing comments")
    comment = post.comments.create!(body: "Original comment", created_by: user)

    post user_session_path, params: { user: { email: user.email, password: "password" } }

    patch post_comment_path(post, comment), params: { comment: { body: "Edited comment" } }

    comment.reload
    assert_equal "Edited comment", comment.body.to_plain_text
  end

  test "authenticated user can get edit modal for their own comment" do
    user = User.create!(email: "edit_modal_user@example.com", password: "password", username: "editmodaluser", confirmed_at: Time.current)
    post_record = user.posts.create!(body: "Post for editing comments modal")
    comment = post_record.comments.create!(body: "Comment to edit in modal", created_by: user)

    post user_session_path, params: { user: { email: user.email, password: "password" } }

    get edit_post_comment_path(post_record, comment)
    assert_response :success
    assert_select "turbo-frame[id=?]", "comment_#{comment.id}" do
      assert_select ".modal"
      assert_select ".modal_content"
      assert_select "h1", "Edit Comment"
      assert_select "a.close-btn"
    end
  end

  test "user cannot edit another user's comment" do
    user1 = User.create!(email: "author@example.com", password: "password", username: "author", confirmed_at: Time.current)
    post = user1.posts.create!(body: "Post")
    comment = post.comments.create!(body: "Author's comment", created_by: user1)

    user2 = User.create!(email: "attacker@example.com", password: "password", username: "attacker", confirmed_at: Time.current)
    post user_session_path, params: { user: { email: user2.email, password: "password" } }

    patch post_comment_path(post, comment), params: { comment: { body: "Hacked comment" } }

    comment.reload
    assert_equal "Author's comment", comment.body.to_plain_text
  end

  test "authenticated user can delete their own comment" do
    user = User.create!(email: "deleter@example.com", password: "password", username: "deleter", confirmed_at: Time.current)
    post = user.posts.create!(body: "Post with comment to delete")
    comment = post.comments.create!(body: "Comment to delete", created_by: user)

    post user_session_path, params: { user: { email: user.email, password: "password" } }

    assert_difference "Comment.count", -1 do
      delete post_comment_path(post, comment)
    end
  end

  test "unauthenticated user cannot create comment" do
    user = User.create!(email: "post_owner@example.com", password: "password", username: "postowner", confirmed_at: Time.current)
    post = user.posts.create!(body: "Post for unauth comment")

    assert_no_difference "Comment.count" do
      post post_comments_path(post), params: { comment: { body: "Unauthorized" } }
    end

    assert_redirected_to new_user_session_path
  end

  test "comment requires body" do
    user = User.create!(email: "validator@example.com", password: "password", username: "validator", confirmed_at: Time.current)
    post = user.posts.create!(body: "Post for validation")

    post user_session_path, params: { user: { email: user.email, password: "password" } }

    assert_no_difference "Comment.count" do
      post post_comments_path(post), params: { comment: { body: "" } }
    end
  end

  test "authenticated user can view large_image for comment" do
    user = User.create!(email: "viewer@example.com", password: "password", username: "viewer", confirmed_at: Time.current)
    post_record = user.posts.create!(body: "Post with comment")
    comment = post_record.comments.create!(body: "Comment to view image", created_by: user)

    post user_session_path, params: { user: { email: user.email, password: "password" } }

    get large_image_post_comment_path(post_record, comment)
    assert_response :success
    assert_select "turbo-frame[id=?]", "comment_#{comment.id}" do
      assert_select ".modal"
      assert_select "a.close-btn[href=?]", post_comment_path(post_record, comment)
    end
  end

  test "comment show action renders comment in turbo frame or redirects to post" do
    user = User.create!(email: "shower@example.com", password: "password", username: "shower", confirmed_at: Time.current)
    post_record = user.posts.create!(body: "Post for comment show")
    comment = post_record.comments.create!(body: "Show comment", created_by: user)

    post user_session_path, params: { user: { email: user.email, password: "password" } }

    # Turbo frame request (e.g. from closing the modal)
    get post_comment_path(post_record, comment), headers: { "Turbo-Frame" => "comment_#{comment.id}" }
    assert_response :success
    assert_select "turbo-frame[id=?]", "comment_#{comment.id}"

    # Non-turbo-frame request redirects to post anchor
    get post_comment_path(post_record, comment)
    assert_redirected_to "#{post_path(post_record)}#comment_#{comment.id}"
  end

  test "creating a comment from new comments modal on hashtag page does not display Commented on post by dialog" do
    user = User.create!(email: "modal_commenter@example.com", password: "password", username: "modalcommenter", confirmed_at: Time.current)
    post_record = user.posts.create!(body: "Post on #beer hashtag")

    post user_session_path, params: { user: { email: user.email, password: "password" } }

    # Open the new comments modal with referer set to /hashtags/beer
    get new_post_comment_path(post_record), headers: { "HTTP_REFERER" => "http://www.example.com/hashtags/beer" }
    assert_response :success
    assert_not_includes @response.body, "Commented on post by"
    assert_not_includes @response.body, "comment-feed-context"

    # Create a comment with referer set to /hashtags/beer
    post post_comments_path(post_record),
         params: { comment: { body: "Tasty #beer review!" } },
         headers: { "HTTP_REFERER" => "http://www.example.com/hashtags/beer", "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_not_includes @response.body, "Commented on post by"
    assert_not_includes @response.body, "comment-feed-context"
  end

  test "updating comment with missing or non-blob attachment does not raise NoMethodError audio?" do
    user = User.create!(email: "audio_tester@example.com", password: "password", username: "audiotester", confirmed_at: Time.current)
    post_record = user.posts.create!(body: "Post with comment to update")
    comment = post_record.comments.create!(body: "Initial comment", created_by: user)

    post user_session_path, params: { user: { email: user.email, password: "password" } }

    # Body containing action-text-attachment without a valid blob/sgid
    broken_attachment_body = '<div><figure data-trix-attachment="{&quot;contentType&quot;:&quot;image/jpeg&quot;,&quot;filename&quot;:&quot;test.jpg&quot;,&quot;href&quot;:&quot;/hashtags/beer&quot;}"><img src="blob:http://localhost/test"><figcaption>test.jpg</figcaption></figure>Drinking <a href="/hashtags/beer">#beer</a></div>'

    patch post_comment_path(post_record, comment),
          params: { comment: { body: broken_attachment_body } },
          headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_includes @response.body, "Drinking"
    assert_includes @response.body, "#beer"
  end
end
