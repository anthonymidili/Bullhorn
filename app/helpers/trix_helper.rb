module TrixHelper
  def formated_text(object)
    raw_html = object.try(:body).try(:body).try(:to_s)
    return "".html_safe if raw_html.blank?

    cleaned_html = raw_html.gsub(/<action-text-attachment\s+[^>]*>.*?<\/action-text-attachment>/m, "")
    render_mentions_and_hashtags_in_html(cleaned_html)
  end

  def attachments(object)
    object.try(:body).try(:body).try(:attachments)
  end
end
