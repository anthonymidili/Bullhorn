class Post < ApplicationRecord
  after_commit on: [ :create ] do
    NotifierJob.perform_later(self)
  end

  has_rich_text :body

  belongs_to :user

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  # Post that reposted a post.
  has_one :repost, dependent: :destroy
  has_one :reposting, through: :repost, source: :reposted
  # Posts that have been reposted by other posts.
  has_many :reposts, foreign_key: :reposted_id,
  class_name: "Repost", dependent: :destroy
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

  def self.suggested_for(user)
    # Posts from users that your followers follow (followers-of-followers)
    # Prioritized by engagement (likes + comments) and recency

    # Get IDs of users that the current user's followers follow
    followers_of_followers_ids = User
      .joins(:relationships)
      .where(relationships: { user_id: user.followers.select(:id) })
      .distinct
      .pluck(:id)

    # Exclude users the current user already follows and themselves
    following_ids = user.following.ids << user.id
    suggested_user_ids = followers_of_followers_ids - following_ids

    # If no suggested users, show trending posts from everyone (except current user)
    if suggested_user_ids.empty?
      suggested_user_ids = User.where.not(id: user.id).pluck(:id)
    end

    # Return posts from these users, ordered by engagement then recency
    where(user_id: suggested_user_ids)
      .select("posts.*, COUNT(DISTINCT likes.id) as likes_count, COUNT(DISTINCT comments.id) as comments_count")
      .left_joins(:likes, :comments)
      .group("posts.id")
      .order(Arel.sql("likes_count DESC, comments_count DESC, posts.created_at DESC"))
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

  def has_media?
    !!body.body && body.body.attachments.any?
  end
end
