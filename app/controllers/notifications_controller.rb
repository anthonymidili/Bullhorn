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
      # Determine which form was submitted and update accordingly
      if params[:receive_mail].present?
        if @receive_mail.update(receive_mail_params)
          format.html {
            redirect_to edit_notifications_path,
            notice: "Email notification settings were successfully updated."
          }
          format.json { render :show, status: :ok, location: @receive_mail }
        else
          format.html { render :edit }
          format.json { render json: @receive_mail.errors, status: :unprocessable_entity }
        end
      elsif params[:receive_push].present?
        if @receive_push.update(receive_push_params)
          format.html {
            redirect_to edit_notifications_path,
            notice: "Push notification settings were successfully updated."
          }
          format.json { render :show, status: :ok, location: @receive_push }
        else
          format.html { render :edit }
          format.json { render json: @receive_push.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to edit_notifications_path, alert: "No settings to update." }
        format.json { head :bad_request }
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
