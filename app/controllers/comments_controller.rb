class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_commentable, only: [:create]

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.created_by_user = current_user
    @micropost = Micropost.find(params[:micropost_id])

    if @comment.save
      notify_post_owner!
      notify_commenters!
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path,
                                    notice: 'Your comment was successfully posted!' }
        format.js
      end
    else
      redirect_back fallback_location: root_path, notice: "Your comment wasn't posted!"
    end
  end

  def destroy
    @comment = current_user.comments.find(params[:id]).destroy
    redirect_back fallback_location: root_path, notice: 'Comment was successfully destroyed.'
  end

private

  def comment_params
    params.require(:comment).permit(:content)
  end

  def find_commentable
    @commentable =
        if params[:comment_id]
          Comment.find_by(id: params[:comment_id])
        elsif params[:micropost_id]
          Micropost.find_by(id: params[:micropost_id])
        end
  end

  def notify_post_owner!
    NotifierMailer.alert_post_owner(@micropost.user, current_user, @micropost).deliver_now unless @micropost.user == current_user
  end

  def notify_commenters!
    @micropost.commenters(current_user, @micropost.user).each do |user|
      NotifierMailer.alert_commenters(user, current_user, @micropost).deliver_now
    end
  end
end
