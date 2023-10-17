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

  def profile_or_edit(user)
    if correct_user?(user) && @to_edit
      edit_user_path(user)
    else
      user
    end
  end
end
