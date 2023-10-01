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
    elsif @from_controller == "events" && @from_action == "index"
      events_objects
    elsif @from_controller == "posts" && @from_action == "show"
      post_comment_objects
    elsif @from_controller == "events" && @from_action == "show"
      event_comment_objects
    end
  end

  def sites_objects
    setup_page
    @objects =
      Post.by_following(current_user).with_attached_images
      .includes(:likes, :comments, user: [avatar_attachment: :blob])
    @append_to = "posts"
    set_scrolled_objects
    set_next_page
  end

  def users_objects
    setup_page
    @user = User.find_by(id: @id)
    @objects = 
      @user.posts.with_attached_images
      .includes(:likes, :comments, user: [avatar_attachment: :blob])
    @append_to = "posts"
    set_scrolled_objects
    set_next_page
  end

  def events_objects
    setup_page
    @objects = 
      current_user.relevant_events.from_the_past.
      with_attached_image.includes(:comments, :address, user: [avatar_attachment: :blob])
    @append_to = "past_events"
    set_scrolled_objects
    set_next_page
  end

  def post_comment_objects
    setup_page
    @post = Post.with_attached_images.includes(comments: :created_by).find_by(id: @id)
    @objects = @post.comments
    @append_to = "comments"
    set_scrolled_objects
    set_next_page
  end

  def event_comment_objects
    setup_page
    @event = current_user.relevant_events.with_attached_image.
    includes(comments: :created_by, users: [avatar_attachment: :blob]).
    find_by(id: params[:id])
    @objects = @event.comments
    @append_to = "comments"
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
