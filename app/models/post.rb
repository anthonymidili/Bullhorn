class Post < ApplicationRecord
  after_commit on: [:create] do
    NotifierJob.perform_later(self)
  end

  belongs_to :user

  has_many_attached :images
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  has_one :repost, dependent: :destroy
  has_one :reposting, through: :repost, source: :reposted
  has_many :reposts, foreign_key: :reposted_id, 
  class_name: 'Repost', dependent: :destroy
  has_many :repostings, through: :reposts, source: :post

  # validates :body, presence: true
  validates :images, file_content_type: {
    allow: ['image/jpg', 'image/jpeg', 'image/gif', 'image/png']
  }, if: -> { images.attached? }

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

  def users_who_reposted
    users = repostings.pluck(:user_id)
    User.where(id: users)
  end
  
  default_scope { order(created_at: :desc) }

  def self.by_following(user)
    following_ids = user.following.ids << user.id
    where(user_id: following_ids)
  end

  def self.with_images
    ActiveStorage::Attachment.includes(:record, :blob).
    where(record_type: 'Post', record_id: pluck(:id)).
    order(created_at: :desc)
  end
end
