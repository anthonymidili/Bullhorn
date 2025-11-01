class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_timezone
  include UsersHelper
  include NotificationsHelper

  def set_timezone
    @set_timezone ||=
      if user_signed_in?
        unless current_user.timezone
          current_user.update_attribute(:timezone, "Eastern Time (US & Canada)")
        end
        Time.zone = current_user.timezone
      end
  end

  def deny_access!
    redirect_to root_path
  end

  def set_return_to
    @set_return_to ||=
      cookies[:return_to] = params[:return_to]
  end; helper_method :set_return_to

protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username ])
  end
end
