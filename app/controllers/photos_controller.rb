class PhotosController < ApplicationController
  before_action :signed_in_user
  before_action :set_photo, only: [:show, :edit, :update, :destroy]

  # GET /photos/1
  def show
  end

  # GET /photos/1/edit
  def edit
  end

  # PATCH/PUT /photos/1
  def update
    if @photo.update(photo_params)
      redirect_to album_path, notice: 'Photo was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /photos/1
  def destroy
    @photo.destroy
    redirect_to album_path, notice: 'Photo was successfully destroyed.'
  end

  def view_photos
    @user = User.find(params[:id])
    @photos = @user.photos.by_newest
  end

  def view_photo
    @user = User.find(params[:id])
    @photo = @user.photos.find(params[:photo_id])
  end

  def full_size
    @user = User.find(params[:id])
    @photo = @user.photos.find(params[:photo_id])
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_photo
    @photo = current_user.photos.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def photo_params
    params.require(:photo).permit(:caption)
  end
end
