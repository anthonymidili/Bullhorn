class ThemeController < ApplicationController
  def update
    if theme_params.blank?
      cookies.delete(:theme)
    else
      cookies.permanent[:theme] = theme_params[:theme]
    end
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to(request.referrer || root_path, notice: "Theme updated.") }
    end
  end

private
  # Only allow a list of trusted parameters through.
  def theme_params
    params.permit(:theme)
  end
end
