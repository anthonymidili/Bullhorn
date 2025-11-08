class ThemeController < ApplicationController
  def update
    if theme_params.blank?
      cookies.delete(:theme)
    else
      cookies.permanent[:theme] = theme_params[:theme]
    end
    redirect_to(request.referrer || root_path)
  end

private
  # Only allow a list of trusted parameters through.
  def theme_params
    params.permit(:theme)
  end
end
