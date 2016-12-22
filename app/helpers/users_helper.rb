module UsersHelper

  def avatar_for(user, size)
    if user.avatar
      image_tag(user.avatar.image.thumb, size: size, class: 'avatar')
    else
      image_tag('default_avatar.png', size: size, class: 'avatar')
    end
  end

  def button_size(param_action)
    param_action == 'show' ? 'large' : 'small'
  end
end
