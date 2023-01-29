class TimezonesController < ApplicationController
  before_action :authenticate_user!

  def edit
    set_return_to if params[:return_to]
  end

  def update
    if current_user.update(user_params)
      set_timezone
      redirect_to cookies[:return_to]
    end
  end

private

  def user_params
    params.require(:user).permit(:timezone)
  end
end
