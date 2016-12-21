module PhotosHelper
  def link_to_photos(user)
    if current_user?(user)
      link_to 'My photos', album_path
    else
      link_to 'Photos', photos_user_path(user)
    end
  end
end
