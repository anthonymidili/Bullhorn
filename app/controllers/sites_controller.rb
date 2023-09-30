class SitesController < ApplicationController
  include InfiniteScroll
  before_action :render_new_link

  def index
    if user_signed_in?
      @user = current_user
      @post = @user.posts.build
      @posts = @scrolled_objects # Returned objects in batches of 10.
    end
  end

private

  def render_new_link
    if params[:new_link]
      @render_new_link = true
    end
  end
end
