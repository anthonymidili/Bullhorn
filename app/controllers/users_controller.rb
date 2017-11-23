class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_user, only: :destroy

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page]).includes(:user, :photo)
    @profile_feed = true
    @button_size = 'large'
  end

  def index
    @users = User.paginate(page: params[:page], per_page: 20).includes(:avatar, :microposts)
    @button_size = 'small'
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'User destroyed'
    redirect_to users_path
  end

  def following
    @title = 'Following'
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = 'Followers'
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  def search
    @users = User.by_search(params[:term])
    render json: @users.pluck(:name).as_json
  end

private

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end
end
