module TrixHelper
  def formated_text(object)
    raw_html = object.try(:body).try(:body).try(:to_s)
    return "".html_safe if raw_html.blank?

    cleaned_html = raw_html.gsub(/<action-text-attachment\s+[^>]*>.*?<\/action-text-attachment>/m, "")
    render_mentions_and_hashtags_in_html(cleaned_html)
  end

  def attachments(object)
    atts = object.try(:body).try(:body).try(:attachments)
    return [] unless atts

    atts.select do |att|
      att.respond_to?(:attachable) && att.attachable.is_a?(ActiveStorage::Blob)
    end
  end
end
