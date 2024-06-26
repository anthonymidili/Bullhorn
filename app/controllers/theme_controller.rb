class ThemeController < ApplicationController
  def update
    if params[:theme].blank?
      cookies.delete(:theme)
    else
      cookies.permanent[:theme] = params[:theme]
    end
    redirect_to(request.referrer || root_path)
  end
end
