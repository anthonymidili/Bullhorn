module InfiniteScroll
  extend ActiveSupport::Concern

  included do
    before_action :setup_page
    before_action :set_objects
    before_action :set_scrolled_objects
    before_action :set_next_page
  end

  def setup_page
    @from_controller = params[:from_controller] || self.controller_name
    @page_limit = 10
    @current_page = params[:page].to_i
    @id = params[:id]
  end
    
  # Load objects to infinately scroll and where to append them.
  def set_objects
    case @from_controller
    when "sites"
      @objects =
        Post.by_following(current_user)
        .with_attached_images
        .includes(user: [avatar_attachment: :blob])
      @append_to = "posts"
    when "users"
      @user = User.find_by(id: params[:id])
      @objects = @user.posts.with_attached_images
      @append_to = "posts"
    else
      raise StandardError.new "Could not find object to set in app/controllers/concerns/InfiniteScroll.rb set_objects"
    end
  end

  # Return @scrolled_objects in batches of page_limit(10).
  def set_scrolled_objects
    @scrolled_objects = 
      @objects.offset(@page_limit * @current_page).limit(@page_limit)
  end

  # Increment next page by 1 if all objects count is greater than 
  # page_limit * current_page + page_limit (10, 20, 30), ect.
  def set_next_page
    if @objects.count > @page_limit * @current_page + @page_limit
      @next_page = @current_page + 1 
    end
  end
end
