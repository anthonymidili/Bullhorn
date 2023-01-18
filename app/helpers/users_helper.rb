module UsersHelper
  def correct_user?(user)
    current_user == user
  end

  def authenticate_admin!
    redirect_to root_path unless current_user.is_admin
  end

  def admin_form(user)
    if user.is_admin
      'users/remove_admin'
    else
      'users/add_admin'
    end
  end

  def link_to_user_resume(resume)
    if resume
      link_to 'Edit your Resume', edit_resume_path(resume), class: 'btn btn-primary'
    else
      link_to 'Post your Resume', new_resume_path, class: 'btn btn-primary'
    end
  end
end
