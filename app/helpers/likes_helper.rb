module LikesHelper
  def path_to_who_liked(likeable)
    ("/#{likeable.class.name.tableize}/#{likeable.id}/who_liked").html_safe
  end
end
