class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def show
    @recent_notifications = current_user.notifications.recent.
    includes(:notifiable, notifier: [avatar_attachment: :blob])
    @earlier_notifications = current_user.notifications.earlier.
    includes(:notifiable, notifier: [avatar_attachment: :blob])
  end

  def edit
    @receive_mail = current_user.receive_mail || current_user.create_receive_mail
  end

  def update
    @receive_mail = current_user.receive_mail

    respond_to do |format|
      if @receive_mail.update(receive_mail_params)
        format.html {
          redirect_to root_path,
          notice: 'Notification settings were successfully updated.'
        }
        format.json { render :show, status: :ok, location: @receive_mail }
      else
        format.html { render edit_notifications_path }
        format.json { render json: @receive_mail.errors, status: :unprocessable_entity }
      end
    end
  end

  def mark_all_as_read
    current_user.notifications.where(is_read: false).
    update_all(is_read: true)
    respond_to do |format|
      format.html {
        redirect_to root_path,
        notice: 'ALL Notification were marked as read.'
      }
    end
  end

private

  def receive_mail_params
    params.require(:receive_mail).permit(:for_new_posts,
      :for_new_events, :for_new_job_listings, :for_new_comments)
  end
end
