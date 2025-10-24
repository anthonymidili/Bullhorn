Rails.application.config.after_initialize do
  ActionText::Attachments::TrixConversion.class_eval do
    def to_trix_attachment(content = trix_attachment_content)
      attributes = full_attributes.dup
      attributes["content"] = content if content
      if previewable_attachable? && previewable? && preview_image.try(:blob)
        attributes["url"] =
          Rails.application.routes.url_helpers.
          rails_blob_url(preview_image.blob, only_path: true)
      end
      ActionText::TrixAttachment.from_attributes(attributes)
    end
  end
  ActionText::ContentHelper.sanitizer.class.allowed_attributes += %w[ style controls poster data-action data-media-target ]
  ActionText::ContentHelper.sanitizer.class.allowed_tags += %w[ video audio source embed iframe ]
end
