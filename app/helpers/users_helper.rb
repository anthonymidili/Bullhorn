module UsersHelper

  def avatar_for(user, size)
    image_tag(select_avatar_for(user), size: size, alt: user.name, class: 'avatar')
  end

  def smaller_col_for_admin
    current_user_admin? ? 8 : 10
  end

private

  def select_avatar_for(user)
    user.avatar ? user.avatar.image.thumb.url : 'default_avatar.svg'
  end
end
