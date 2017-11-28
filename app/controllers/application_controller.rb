class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  protect_from_forgery

  def current_user?(user)
    user == current_user
  end; helper_method :current_user?

  def current_user_feed
    current_user.feed.paginate(page: params[:page])
  end

  def current_user_admin?
    current_user.admin?
  end; helper_method :current_user_admin?

  def profile_user
    @profile_user ||=
      User.find_by(id: session[:profile_user_id]) || current_user
  end; helper_method :profile_user

protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit(:name, :email, :password, :password_confirmation)
    end

    devise_parameter_sanitizer.permit(:account_update) do |user_params|
      user_params.permit(:name, :email, :password, :password_confirmation, :current_password)
    end
  end
end
