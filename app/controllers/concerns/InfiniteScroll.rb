module InfiniteScroll
  extend ActiveSupport::Concern

  included do
    before_action :set_from_controller
    before_action :set_objects
  end

  def set_from_controller
    @from_controller = params[:from_controller] || self.controller_name
    @from_action = params[:from_action] || self.action_name
  end
    
  # Load objects to infinately scroll and where to append them.
  def set_objects
    if @from_controller == "sites" && @from_action == "index"
      sites_objects
    elsif @from_controller == "users" && @from_action == "show"
      users_objects
    end
  end

  def sites_objects
    setup_page
    @objects =
      Post.by_following(current_user)
      .with_attached_images
      .includes(user: [avatar_attachment: :blob])
    @append_to = "posts"
    set_scrolled_objects
    set_next_page
  end

  def users_objects
    setup_page
    @user = User.find_by(id: @id)
    @objects = @user.posts.with_attached_images
    @append_to = "posts"
    set_scrolled_objects
    set_next_page
  end

  def setup_page
    @page_limit = 10
    @current_page = params[:page].to_i
    @id = params[:id]
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
