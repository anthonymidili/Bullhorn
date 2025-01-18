class Comment < ApplicationRecord
  after_commit on: [ :create ] do
    NotifierJob.perform_later(self)
  end

  belongs_to :commentable, polymorphic: true
  belongs_to :created_by, class_name: "User", foreign_key: "created_by_id"

  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy

  validates :body, presence: true

  include ReadNotifications
  # def read_user_notifications(current_user)
  #   self.notifications.by_unread.where(recipient: current_user).
  #   update_all(is_read: true)
  #   read_comment_notifications(current_user) if self.try(:comments)
  #   read_like_notifications(current_user) if self.try(:likes)
  # end

  include LikeableUsers
  # def users_who_liked
  #   users = self.likes.pluck(:user_id)
  #   User.where(id: users)
  # end

  default_scope { order(created_at: :desc) }

  # Remove comment if comment var is set
  scope :without_current_comment, ->(comment) { where.not(id: comment.try(:id)) }
end
