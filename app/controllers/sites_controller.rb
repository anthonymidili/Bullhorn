class SitesController < ApplicationController
  include InfiniteScroll

  before_action :render_new_link, only: [ :index ]

  def index
    if user_signed_in?
      @user = current_user
      @post = @user.posts.build
      @posts = @scrolled_objects # Returned objects in batches of 10.
    end
  end

  def sitemap
    redirect_to "https://#{Rails.application.credentials.dig(:sitemap, :s3_bucket)}.s3.#{Rails.application.credentials.dig(:aws, :region)}.amazonaws.com/sitemaps/bullhorn/sitemap.xml",
    allow_other_host: true
  end

private

  def render_new_link
    if params[:new_link]
      @render_new_link = true
    end
  end
end
