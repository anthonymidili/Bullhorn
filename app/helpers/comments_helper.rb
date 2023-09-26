module CommentsHelper
  def path_to_commentable(commentable)
    case commentable.class.name
    when 'Post'
      root_path(anchor: "post_#{commentable.id}")
    when 'Event'
      event_path(commentable)
    else
      root_path
    end
  end
end
