class MicropostsController < ApplicationController
  before_action :signed_in_user
  before_action :correct_user, only: :destroy

  def show
    @micropost = Micropost.includes(comments: [:created_by_user, :comments]).find(params[:id])
    @profile_feed = params[:profile_feed]
    @show_comments = true
  end

  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.photo.user = current_user if @micropost.photo

    if @micropost.save
      flash[:success] = 'Micropost created!'
      @micropost.create_mentions(micropost_params[:mentioned])
      current_user.followers.find_each do |user|
        NotifierMailer.alert_followers(user, current_user).deliver_now
      end
      redirect_to root_path
    else
      @microposts = current_user_feed
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    flash[:notice] = 'Micropost was successfully destroyed.'
    redirect_back_or root_path
  end

private

  def micropost_params
    params.require(:micropost).permit(:content, :mentioned, photo_attributes: [:id, :image])
  end

  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    redirect_to root_path unless @micropost
  end
end
