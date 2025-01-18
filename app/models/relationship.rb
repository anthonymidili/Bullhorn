class Relationship < ApplicationRecord
  after_commit on: [ :create ] do
    NotifierJob.perform_later(self)
  end

  has_many :notifications, as: :notifiable, dependent: :destroy

  belongs_to :user, foreign_key: :user_id,
    class_name: "User", inverse_of: :relationships
  belongs_to :followed, foreign_key: :followed_id,
    class_name: "User", inverse_of: :relationships

  include ReadNotifications
  # def read_user_notifications(current_user)
  #   self.notifications.by_unread.where(recipient: current_user).
  #   update_all(is_read: true)
  #   read_comment_notifications(current_user) if self.try(:comments)
  #   read_like_notifications(current_user) if self.try(:likes)
  # end
end
