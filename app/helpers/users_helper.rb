module UsersHelper

  def avatar_for(user, size)
    image_tag(select_avatar_for(user), size: size, alt: user.name, class: 'avatar')
  end

  def button_size(param_action)
    param_action == 'show' ? 'large' : 'small'
  end

private

  def select_avatar_for(user)
    user.avatar ? user.avatar.image.thumb : 'default_avatar.png'
  end
end
