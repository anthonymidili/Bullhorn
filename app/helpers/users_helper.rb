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
end
