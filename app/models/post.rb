class Post < ApplicationRecord
  after_commit on: [:create] do
    NotifierJob.perform_later(self)
  end

  has_rich_text :body

  belongs_to :user
  
  # Need to for old non-trix images.
  has_many_attached :images
  
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  # Post that reposted a post.
  has_one :repost, dependent: :destroy
  has_one :reposting, through: :repost, source: :reposted
  # Posts that have been reposted by other posts.
  has_many :reposts, foreign_key: :reposted_id, 
  class_name: 'Repost', dependent: :destroy
  has_many :repostings, through: :reposts, source: :post

  # validates :body, presence: true

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

  def post_type
    if !!reposting && body?
      "quoted_repost"
    elsif !!reposting
      "repost"
    else
      "post"
    end
  end

  def is_post?
    post_type == "post"
  end

  def is_repost?
    post_type == "repost"
  end

  def is_quoted_repost?
    post_type == "quoted_repost"
  end
end
