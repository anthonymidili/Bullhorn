class StaticPagesController < ApplicationController

  def home
    if signed_in?
      @micropost = current_user.microposts.build
      @microposts = current_user.feed.paginate(page: params[:page]).includes([user: :avatar], :photo)
      session.delete :profile_user_id
      @user = current_user
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
