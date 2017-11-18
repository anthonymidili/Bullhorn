class PhotosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :correct_user, only: [:new, :create, :edit, :update, :update_avatar, :destroy]
  before_action :set_photo, only: [:show, :edit, :update, :update_avatar, :destroy, :full_size]

  def index
    @photos = @user.photos
  end

  # GET /photos/1
  def show
  end

  def new
    @photo = @user.photos.build
  end

  def create
    @photo = @user.photos.build(photo_params)

    if @photo.save
      redirect_to user_photos_path(@user), notice: 'Photo upload was successfully.'
    else
      render :edit
    end
  end

  # GET /photos/1/edit
  def edit
  end

  # PATCH/PUT /photos/1
  def update
    if @photo.update(photo_params)
      redirect_to user_photos_path(@user), notice: 'Photo was successfully updated.'
    else
      render :edit
    end
  end

  def update_avatar
    @user.avatar = @photo

    if @user.save(validate: false)
      sign_in @user
      redirect_to user_photos_path(@user), notice: 'Your profile photo has been updated.'
    else
      flash[:alert] = 'Something went wrong! Please try again.'
      render 'photos/index'
    end
  end

  # DELETE /photos/1
  def destroy
    @photo.destroy
    redirect_to user_photos_path(@user), notice: 'Photo was successfully destroyed.'
  end

  def full_size
  end

  def presign_upload
    # pass the limit option if you want to limit the file size
    render json: UploadPresigner.presign("/photos/image/", params[:filename], limit: 1.megabyte)
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:user_id])
  end

  def correct_user
    redirect_to(root_path) unless current_user?(@user)
  end

  def set_photo
    @photo = @user.photos.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def photo_params
    params.require(:photo).permit(:image, :caption)
  end
end
