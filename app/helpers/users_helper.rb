module UsersHelper

  def avatar_for(user, size)
    if user.avatar
      image_tag(user.avatar.image.thumb.url, size: size, alt: user.name, class: 'avatar')
    else
      image_pack_tag('default_avatar.svg', size: size, alt: user.name, class: 'avatar')
    end
  end

  def smaller_col_for_admin
    current_user_admin? ? 8 : 10
  end
end
