class SitesController < ApplicationController
  def index
    if user_signed_in?
      @user = current_user
      @post = @user.posts.build
      @posts = Post.by_following(current_user)
      .with_attached_images.includes(user: [avatar_attachment: :blob])
      .page(params[:page]).per(20)
    end
  end
end
