module LikesHelper
  def path_to_who_liked(likeable)
    who_likes_path(like: {
      likeable_type: likeable.class.name,
      likeable_id: likeable.id
    })
  end

  def path_to_likeable(likeable, anchor = nil)
    case likeable.class.name
    when "Post"
      post_url(likeable, anchor: anchor)
    when "Comment"
      path_to_likeable(likeable.commentable, "comment_#{likeable.id}")
    else root_url
    end
  end
end
