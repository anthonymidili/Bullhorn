module MentionAndHashtagHelper
  def render_mentions_and_hashtags_in_html(html)
    return "".html_safe if html.blank?

    doc = Nokogiri::HTML::DocumentFragment.parse(html)
    usernames = doc.text.scan(/(?<=^|[^\w@])@([a-zA-Z0-9_]{1,30})\b/).flatten.uniq
    valid_users = usernames.any? ? User.where(username: usernames).index_by { |u| u.username.downcase } : {}

    doc.xpath(".//text()[not(ancestor::a)]").each do |node|
      text = node.content
      next if text.blank? || (!text.include?("@") && !text.include?("#"))

      escaped = ERB::Util.html_escape(text)

      # Auto-link mentions
      escaped = escaped.gsub(/(?<=^|[^\w@])@([a-zA-Z0-9_]{1,30})\b/) do |match|
        username = Regexp.last_match(1)
        user = valid_users[username.downcase]
        if user
          %(<a href="/users/#{user.id}" class="mention-link" data-turbo-frame="_top">@#{ERB::Util.html_escape(user.username)}</a>)
        else
          match
        end
      end

      # Auto-link hashtags
      escaped = escaped.gsub(/(?<=^|[^\w#])#([a-zA-Z0-9_]+)\b/) do |_match|
        tag = Regexp.last_match(1)
        %(<a href="/hashtags/#{ERB::Util.url_encode(tag)}" class="hashtag-link" data-turbo-frame="_top">##{ERB::Util.html_escape(tag)}</a>)
      end

      node.replace(escaped)
    end

    doc.css("a").each do |link|
      link["data-turbo-frame"] = "_top"
      href = link["href"].to_s
      if href.start_with?("/hashtags/")
        classes = (link["class"] || "").split(" ")
        link["class"] = (classes | ["hashtag-link"]).join(" ")
      elsif href.start_with?("/users/") || href.start_with?("/@")
        classes = (link["class"] || "").split(" ")
        link["class"] = (classes | ["mention-link"]).join(" ")
      end
    end

    doc.to_html.html_safe
  end

  def render_mentions_and_hashtags_in_plain_text(text)
    return "".html_safe if text.blank?

    usernames = text.scan(/(?<=^|[^\w@])@([a-zA-Z0-9_]{1,30})\b/).flatten.uniq
    valid_users = usernames.any? ? User.where(username: usernames).index_by { |u| u.username.downcase } : {}

    escaped = ERB::Util.html_escape(text)

    # Auto-link mentions
    escaped = escaped.gsub(/(?<=^|[^\w@])@([a-zA-Z0-9_]{1,30})\b/) do |match|
      username = Regexp.last_match(1)
      user = valid_users[username.downcase]
      if user
        %(<a href="/users/#{user.id}" class="mention-link" data-turbo-frame="_top">@#{ERB::Util.html_escape(user.username)}</a>)
      else
        match
      end
    end

    # Auto-link hashtags
    escaped = escaped.gsub(/(?<=^|[^\w#])#([a-zA-Z0-9_]+)\b/) do |_match|
      tag = Regexp.last_match(1)
      %(<a href="/hashtags/#{ERB::Util.url_encode(tag)}" class="hashtag-link" data-turbo-frame="_top">##{ERB::Util.html_escape(tag)}</a>)
    end

    escaped.html_safe
  end

  def format_comment_body(body)
    return "" if body.blank?

    linked = render_mentions_and_hashtags_in_plain_text(body)
    simple_format(linked, {}, sanitize: false)
  end
end
