module LikesHelper
  def path_to_likes(likeable)
    ("/#{likeable.class.name.tableize}/#{likeable.id}/likes").html_safe
  end
end
