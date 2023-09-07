module LikesHelper
  def path_to_who_liked(likeable)
    who_likes_path(like: { 
      likeable_type: likeable.class.name, 
      likeable_id: likeable.id 
    })
  end
end
