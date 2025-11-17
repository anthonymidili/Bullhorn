module PostsHelper
  def post_reposting_id(post, reposting = nil)
    if reposting
      "post_#{post.id}_reposting_#{reposting.id}"
    else
      "post_#{post.id}"
    end
  end
end
