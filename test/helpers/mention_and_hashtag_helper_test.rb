require "test_helper"

class MentionAndHashtagHelperTest < ActionView::TestCase
  include MentionAndHashtagHelper

  setup do
    @user = User.create!(email: "helper_test@example.com", password: "password", username: "superstar", confirmed_at: Time.current)
  end

  test "render_mentions_and_hashtags_in_html links existing users and hashtags" do
    html = "<div><p>Hello @superstar and #Bullhorn rocks!</p></div>"
    result = render_mentions_and_hashtags_in_html(html)

    assert_includes result, %(<a href="/users/#{@user.id}" class="mention-link" data-turbo-frame="_top">@superstar</a>)
    assert_includes result, %(<a href="/hashtags/Bullhorn" class="hashtag-link" data-turbo-frame="_top">#Bullhorn</a>)
  end

  test "render_mentions_and_hashtags_in_html leaves nonexistent users unlinked" do
    html = "<p>Hey @ghost_user, what is #up?</p>"
    result = render_mentions_and_hashtags_in_html(html)

    assert_includes result, "@ghost_user"
    assert_not_includes result, %(href="/users/)
    assert_includes result, %(<a href="/hashtags/up" class="hashtag-link" data-turbo-frame="_top">#up</a>)
  end

  test "render_mentions_and_hashtags_in_html does not alter interior text of existing anchor tags but ensures data-turbo-frame" do
    html = '<p>Check <a href="/custom/path">#notatag and @superstar</a> outside @superstar</p>'
    result = render_mentions_and_hashtags_in_html(html)

    assert_includes result, '<a href="/custom/path" data-turbo-frame="_top">#notatag and @superstar</a>'
    assert_includes result, %(<a href="/users/#{@user.id}" class="mention-link" data-turbo-frame="_top">@superstar</a>)
  end

  test "render_mentions_and_hashtags_in_html ensures data-turbo-frame on already linked hashtags from rich text" do
    html = '<div><a href="/hashtags/ruby">#ruby</a> and <a href="/users/superstar">@superstar</a></div>'
    result = render_mentions_and_hashtags_in_html(html)

    assert_includes result, '<a href="/hashtags/ruby" data-turbo-frame="_top" class="hashtag-link">#ruby</a>'
    assert_includes result, '<a href="/users/superstar" data-turbo-frame="_top" class="mention-link">@superstar</a>'
  end

  test "render_mentions_and_hashtags_in_html ignores email addresses" do
    html = "<p>Contact me at user@example.com please</p>"
    result = render_mentions_and_hashtags_in_html(html)

    assert_includes result, "user@example.com"
    assert_not_includes result, "class=\"mention-link\""
  end

  test "render_mentions_and_hashtags_in_plain_text formats plain text safely" do
    text = "Plain text with @superstar and #awesome & <script>alert('xss')</script>"
    result = render_mentions_and_hashtags_in_plain_text(text)

    assert_includes result, %(<a href="/users/#{@user.id}" class="mention-link" data-turbo-frame="_top">@superstar</a>)
    assert_includes result, %(<a href="/hashtags/awesome" class="hashtag-link" data-turbo-frame="_top">#awesome</a>)
    assert_not_includes result, "<script>"
    assert_includes result, "&lt;script&gt;"
  end

  test "format_comment_body wraps in simple_format paragraphs" do
    text = "First line @superstar\n\nSecond line #awesome"
    result = format_comment_body(text)

    assert_includes result, "<p>"
    assert_includes result, %(<a href="/users/#{@user.id}" class="mention-link" data-turbo-frame="_top">@superstar</a>)
    assert_includes result, %(<a href="/hashtags/awesome" class="hashtag-link" data-turbo-frame="_top">#awesome</a>)
  end
end
