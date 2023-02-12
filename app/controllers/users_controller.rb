class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!, only: [:destroy, :admins, 
  :add_admin, :remove_admin]
  before_action :set_user,
  only: [:show, :edit, :update, :destroy, :remove_avatar, :add_admin, 
  :remove_admin, :photos, :followers, :following]
  before_action :deny_access!, only: [:edit, :update, :remove_avatar],
  unless: -> { correct_user?(@user) }

  def index
    @users =
      if params[:search]
        User.by_username.search_by(params[:search]).
        with_attached_avatar.includes(:profile)
      else
        User.by_username.with_attached_avatar.includes(:profile)
      end
    @show_occupation = true
  end

  def show
    @posts = @user.posts.with_attached_images.page(params[:page]).per(20)

    # Mark following notification as read.
    if params[:relationship_id]
      relationship = Relationship.find_by(id: params[:relationship_id])
      relationship.read_user_notifications(current_user) if relationship
    end
  end

  def edit
    @user.profile || @user.build_profile
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'Your profile was updated successfully.'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html {
        redirect_to admins_users_path,
        notice: 'User was successfully destroyed.'
      }
      format.json { head :no_content }
    end
  end

  def remove_avatar
    @user.avatar.purge
    redirect_to edit_user_path(@user), notice: 'Your avatar was remove successfully.'
  end

  def search
    @users = User.search_by(params[:term])
    render json: @users.search_results
  end

  def admins
    @users =
      if params[:search]
        User.by_username.search_by(params[:search]).
        with_attached_avatar.includes(:profile)
      else
        User.by_username.with_attached_avatar.includes(:profile)
      end
  end

  def add_admin
    @user.is_admin = true
    @user.save
    redirect_to admins_users_path
  end

  def remove_admin
    @user.is_admin = false
    @user.save
    redirect_to admins_users_path
  end

  def photos
  end

  def followers
  end

  def following
  end

private

  def set_user
    @user = User.find_by(id: params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :first_name, :last_name, :avatar, :timezone,
      profile_attributes: [:id, :bio, :workplace, :position, :birthday,
      :graduated_in, :show_email, :user_id, :_destroy],
      phones_attributes: [:id, :number, :device, :extension, :_destroy],
      addresses_attributes: [:id, :street_1, :street_2, :city, :state, :zip,
      :location, :_destroy],
      websites_attributes: [:id, :name, :address, :_destroy])
  end
end
