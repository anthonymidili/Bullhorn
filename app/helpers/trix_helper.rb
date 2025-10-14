module TrixHelper
  def formated_text(object)
    raw_html = object.try(:body).try(:body).try(:to_s)
    raw_html.gsub(/<action-text-attachment\s+[^>]*>.*?<\/action-text-attachment>/m, "").html_safe
  end

  def attachments(object)
    object.try(:body).try(:body).try(:attachments)
  end
end
