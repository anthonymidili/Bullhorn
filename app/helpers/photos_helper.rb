module PhotosHelper
  def photos_for(user)
    current_user?(user) ? 'Your photos' : "#{user.name}'s photos"
  end

  def photo_content_span(user)
    current_user?(user) ? 'photo_content_owner' : 'photo_content_viewer'
  end

  def caption_for(user, photo)
    if photo.caption.blank? && current_user?(user)
      'Add caption'
    elsif photo.caption
      photo.caption
    end
  end
end
