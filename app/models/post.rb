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
    # Posts from users that your followers follow (followers-of-followers), ordered by
    # engagement (likes + comments) and recency, with a hard fallback to trending posts
    # from everyone else if that network is empty.

    followers_of_followers_ids = User
      .joins(:relationships)
      .where(relationships: { user_id: user.followers.select(:id) })
      .distinct
      .pluck(:id)

    following_ids = user.following.ids << user.id
    suggested_user_ids = followers_of_followers_ids - following_ids

    engagement_order = Arel.sql("likes_count DESC, comments_count DESC, posts.created_at DESC")

    base_scope = Post
      .unscope(:order) # remove default_scope ordering
      .left_joins(:likes, :comments)
      .select("posts.*, COUNT(DISTINCT likes.id) AS likes_count, COUNT(DISTINCT comments.id) AS comments_count")
      .group("posts.id")

    preferred_scope = if suggested_user_ids.any?
      base_scope.where(user_id: suggested_user_ids)
    else
      base_scope.where.not(user_id: user.id)
    end

    preferred_relation = preferred_scope.order(engagement_order)

    return preferred_relation if preferred_relation.exists?

    # Fallback: trending posts from everyone except the current user
    base_scope
      .where.not(user_id: user.id)
      .order(engagement_order)
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
