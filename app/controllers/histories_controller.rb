class HistoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!, only: [:edit, :update, :remove_image]
  before_action :set_history

  def show
    @past_presidents = PastPresident.with_attached_avatar
  end

  def edit
  end

  def update
    respond_to do |format|
      if @history.update(history_params)
        format.html {
          redirect_to history_path, notice: 'History was successfully updated.'
        }
        format.json { render :show, status: :ok, location: @history }
      else
        format.html { render :edit }
        format.json { render json: @history.errors, status: :unprocessable_entity }
      end
    end
  end

  def remove_image
    @history.images.find_by(id: params[:image_id]).purge
    redirect_to edit_history_path, notice: 'Your image was remove successfully.'
  end

private

  def set_history
    @history = History.with_attached_images.first_or_create(content: 'Coming soon.')
  end

  def history_params
    params.require(:history).permit(:content, images: [])
  end
end
