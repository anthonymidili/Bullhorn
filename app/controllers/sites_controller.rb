class SitesController < ApplicationController
  def index
    if user_signed_in?
      @user = current_user
      @post = @user.posts.build
      # Set number of posts to load at a time.
      page_limit = 10
      # Set current page # from params or return 0.
      @current_page = params[:page].to_i
      # Load all the users that user is following .
      all_posts = Post.by_following(current_user)
      .with_attached_images.includes(user: [avatar_attachment: :blob])
      # Set @posts with the first 10, 20, ect. posts depending on the page #.
      @posts = all_posts.offset(page_limit * @current_page).limit(page_limit)
      # Set next page if all posts count is greater than 10+10, 20+10, ect.
      if all_posts.count > page_limit * @current_page + page_limit
        @next_page = @current_page + 1 
      end
    end
  end
end
