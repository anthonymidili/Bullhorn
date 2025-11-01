class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_commentable
  before_action :set_comment, only: [ :edit, :update, :destroy ]
  before_action :deny_access!, only: [ :edit, :update, :destroy ],
  unless:  -> { correct_user?(@comment.created_by) }

  # GET /comments/new
  def new
    @comment = @commentable.comments.build
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.created_by = current_user

    respond_to do |format|
      if @comment.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.prepend("comments",
            partial: "comments/comment",
            locals: { comment: @comment }),
            turbo_stream.replace("form_#{helpers.dom_id(@commentable)}_new_comment",
            partial: "comments/form",
            locals: { commentable: @commentable, comment: @commentable.comments.build })
          ]
        end
        format.html {
          redirect_to @commentable, notice: "Comment was successfully created."
        }
        format.json { render :show, status: :created, location: @comment }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("form_#{helpers.dom_id(@commentable)}_new_comment",
            partial: "comments/form",
            locals: { commentable: @commentable, comment: @comment })
          ]
        end
        format.html { render :new }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(@comment,
            partial: "comments/comment",
            locals: { comment: @comment })
          ]
        end
        format.html {
          redirect_to @commentable, notice: "Comment was successfully updated."
        }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("form_#{helpers.dom_id(@commentable)}_#{helpers.dom_id(@comment)}",
            partial: "comments/form",
            locals: { commentable: @commentable, comment: @comment })
          ]
        end
        format.html { render :edit }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment.destroy
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.remove(@comment)
      }
      format.html {
        redirect_to @commentable, notice: "Comment was successfully destroyed."
      }
      format.json { head :no_content }
    end
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_commentable
    @commentable =
      if post_id = params[:post_id]
        Post.all.find_by(id: post_id)
      elsif event_id = params[:event_id]
        Event.all.find_by(id: event_id)
      end
  end

  def set_comment
    @comment = @commentable.comments.find_by(id: params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def comment_params
    params.require(:comment).permit(:body)
  end
end
