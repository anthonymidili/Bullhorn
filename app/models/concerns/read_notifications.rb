module ReadNotifications
  extend ActiveSupport::Concern

  def read_user_notifications(current_user)
    if self.class.name == "Direct"
      read_message_notifications(current_user)
    else
      self.notifications.by_unread.where(recipient: current_user).
      update_all(is_read: true)
      read_comment_notifications(current_user) if self.try(:comments)
      read_like_notifications(current_user) if self.try(:likes)
    end
  end

protected

  def read_comment_notifications(current_user)
    comments.each do |comment|
      comment.notifications.by_unread.where(recipient: current_user).
      update_all(is_read: true)
      comment.read_like_notifications(current_user)
    end
  end

  def read_like_notifications(current_user)
    likes.each do |like|
      like.notifications.by_unread.where(recipient: current_user).
      update_all(is_read: true)
    end
  end

  def read_message_notifications(current_user)
    messages.each do |message|
      message.notifications.by_unread.where(recipient: current_user).
      update_all(is_read: true)
    end
  end
end
