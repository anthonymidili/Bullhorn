class UsersController < ApplicationController
  before_filter :signed_in_user, except: [:new, :create]
  before_filter :correct_user, only: [:edit, :update, :update_avatar]
  before_filter :admin_user, only: :destroy

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def index
    @users = User.paginate(page: params[:page], per_page: 20)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = 'You have successfully created your Bullhorn account!'
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = 'Profile updated'
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'User destroyed.'
    redirect_to users_path
  end

  def following
    @title = 'Following'
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  def update_avatar
    @photo = @user.photos.find(params[:photo_id])
    @user.avatar = @photo

    if @user.save(validate: false)
      sign_in @user
      redirect_to album_path, notice: 'Your profile photo has been updated.'
    else
      flash[:alert] = 'Something went wrong! Please try again.'
      render 'albums/show'
    end
  end

private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end
end
