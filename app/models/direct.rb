class Direct < ApplicationRecord
  has_many :conversations, dependent: :destroy
  has_many :users, through: :conversations
  has_many :messages, dependent: :destroy

  validate :user_selected

  include ReadNotifications
  # def read_user_notifications(current_user)
  #   self.notifications.by_unread.where(recipient: current_user).
  #   update_all(is_read: true)
  #   read_comment_notifications(current_user) if self.try(:comments)
  #   read_like_notifications(current_user) if self.try(:likes)
  # end

  def unread_messages_count(current_user)
    current_user.notifications.where(
      notifiable: messages, 
      is_read: false
    ).count
  end

private

  def user_selected
    errors.add(:base, 'Search and select a user to message.') unless users.length > 0
  end
end
