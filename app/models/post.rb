class Post < ApplicationRecord
  after_commit on: [:create] do
    NotifierJob.perform_later(self)
  end

  belongs_to :user

  has_many_attached :images
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :images, file_content_type: {
    allow: ['image/jpg', 'image/jpeg', 'image/gif', 'image/png']
  }, if: -> { images.attached? }

  include ReadNotifications
  # def read_user_notifications(current_user)
  #   notifications.by_unread.where(recipient: current_user).
  #   update_all(is_read: true)
  #   read_comment_notifications(current_user)
  # end
  # def read_comment_notifications(current_user)
  #   comments.each do |comment|
  #     comment.notifications.by_unread.where(recipient: current_user).
  #     update_all(is_read: true)
  #   end
  # end

  default_scope { order(created_at: :desc) }

  def self.with_images
    ActiveStorage::Attachment.includes(:record, :blob).
    where(record_type: 'Post', record_id: pluck(:id)).
    order(created_at: :desc)
  end
end
