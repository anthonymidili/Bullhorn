module ReadNotifications
  extend ActiveSupport::Concern

  def read_user_notifications(current_user)
    notifications.by_unread.where(recipient: current_user).
    update_all(is_read: true)
    read_comment_notifications(current_user) if self.try(:comments)
  end

private

  def read_comment_notifications(current_user)
    comments.each do |comment|
      comment.notifications.by_unread.where(recipient: current_user).
      update_all(is_read: true)
    end
  end
end
