module ImageProcessingHelper
  def medium_image(image)
    image.variant(resize_to_limit: [600, 600])
  end

  def thumb_image(image)
    image.variant(resize_to_fill: [250, 250]).processed.url
  end

  def display_file(file)
    if file.variable?
      link_to image_tag(file.variant(resize_to_limit: [1000, 1000])),
      rails_blob_path(file, disposition: :attachment)
    elsif file.previewable?
      link_to image_tag(file.preview(resize_to_limit: [1000, 1000])),
      rails_blob_path(file, disposition: :attachment)
    elsif file.image?
      link_to image_tag(file, width: 1000), file
    else
      link_to file.filename, rails_blob_path(file, disposition: :attachment)
    end
  end
end
