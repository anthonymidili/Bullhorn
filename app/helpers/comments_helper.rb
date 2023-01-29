module CommentsHelper
  def comment_count(commentable)
    comments_count = commentable.comments.count
    case comments_count
    when 0
      'Create a Comment'
    when 1
      "View #{comments_count} Comment - Create a Comment"
    else
      "View #{comments_count} Comments - Create a Comment"
    end
  end

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
