class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def show
    @recent_notifications = current_user.notifications.bell_messages.recent
    @earlier_notifications = current_user.notifications.bell_messages.earlier
  end

  def edit
    @receive_mail = current_user.receive_mail || current_user.create_receive_mail
    @receive_push = current_user.receive_push || current_user.create_receive_push
  end

  def update
    @receive_mail = current_user.receive_mail
    @receive_push = current_user.receive_push

    respond_to do |format|
      mail_updated = params[:receive_mail].present? ? @receive_mail.update(receive_mail_params) : true
      push_updated = params[:receive_push].present? ? @receive_push.update(receive_push_params) : true

      if mail_updated && push_updated
        format.html { head :no_content }
        format.turbo_stream { head :no_content }
        format.json { render :show, status: :ok, location: @receive_mail }
      else
        format.html { render :edit, status: :unprocessable_entity }
        errors = @receive_mail.errors.messages.merge(@receive_push.errors.messages)
        format.json { render json: errors, status: :unprocessable_entity }
      end
    end
  end

  def mark_all_as_read
    current_user.notifications.where(is_read: false).
    update_all(is_read: true)
    respond_to do |format|
      format.html {
        redirect_to root_path,
        notice: "ALL Notification were marked as read."
      }
    end
  end

private

  def receive_mail_params
    params.require(:receive_mail).permit(:for_new_posts,
      :for_new_events, :for_new_comments, :for_new_relationships,
      :for_new_likes, :for_new_messages, :send_after_amount, :send_after_unit)
  end

  def receive_push_params
    params.require(:receive_push).permit(:for_new_posts,
      :for_new_events, :for_new_comments, :for_new_relationships,
      :for_new_likes, :for_new_messages, :send_after_amount, :send_after_unit)
  end
end
