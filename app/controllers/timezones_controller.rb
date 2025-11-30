class TimezonesController < ApplicationController
  before_action :authenticate_user!

  def edit
    set_return_to if params[:return_to]
  end

  def update
    if current_user.update(user_params)
      set_timezone
      redirect_to helpers.safe_return_path, notice: "Timezone updated successfully."
    else
      render :edit
    end
  end

private

  def user_params
    params.require(:user).permit(:timezone)
  end
end
