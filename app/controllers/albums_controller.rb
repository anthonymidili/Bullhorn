class AlbumsController < ApplicationController
  def show
    current_user.create_album unless current_user.album
    @album = current_user.album
  end

  def edit
    @album = current_user.album
  end

  def update
    @album = current_user.album

    if @album.update(album_params)
      redirect_to album_path, notice: 'Upload was successfully.'
    else
      render :edit
    end
  end

private

  # Only allow a trusted parameter "white list" through.
  def album_params
    params.require(:album).permit(photos_attributes: [:image])
  end
end