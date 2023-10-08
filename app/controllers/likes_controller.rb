class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_likeable
  before_action :set_like

  def create
    respond_to do |format|
      if @like.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              helpers.dom_id(@likeable, "likes_form"),
              partial: "likes/form", locals: { likeable: @likeable }
            ),
            turbo_stream.replace(
              helpers.dom_id(@likeable, "who_liked"),
              partial: "likes/count", locals: { likeable: @likeable }
            )
          ]      
        end
        format.html {
          redirect_back(fallback_location: root_path, notice: 'Successfully liked.')
        }
        format.json { render :show, status: :created, location: @likeable }
      else
        format.html { 
          redirect_back(fallback_location: root_path, notice: 'Like already exists.')
        }
        format.json { render json: @likeable.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @like.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            helpers.dom_id(@likeable, "likes_form"),
            partial: "likes/form", locals: { likeable: @likeable }
          ),
          turbo_stream.replace(
            helpers.dom_id(@likeable, "who_liked"),
            partial: "likes/count", locals: { likeable: @likeable }
          )
        ]      
      end
      format.html {
        redirect_back(fallback_location: root_path, notice: 'Successfully Unliked.')
      }
    end
  end

  def who
  end

private

  def like_params
    params.require(:like).permit(:likeable_id, :likeable_type)
  end

  def set_likeable
    @likeable = like_params[:likeable_type].constantize.find(like_params[:likeable_id])
  end

  def set_like
    @like = 
      current_user.has_liked?(@likeable) || current_user.likes.build(like_params)
  end
end
