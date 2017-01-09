class Micropost < ApplicationRecord
  # attr_accessible :content
  belongs_to :user
  belongs_to :photo

  accepts_nested_attributes_for :photo, reject_if: :all_blank
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :mentions, dependent: :destroy
  has_many :users, through: :mentions

  attr_accessor :mentioned

  validates :content, presence: true, length: {maximum: 1000}
  validates :user_id, presence: true

  default_scope { order(created_at: 'DESC') }

  scope :from_users_followed_by, -> (user) { own_and_followers(user).or(mentioned_in(user)) }
  scope :own_and_followers, -> (user) { where(user_id: followed_user_ids(user) << user.id) }
  scope :followed_user_ids, -> (user) { user.relationships.pluck(:followed_id).uniq }
  scope :mentioned_in, -> (user) { where(id: user.mentions.pluck(:micropost_id)) }

  def commenters(sender, owner)
    comments.map(&:created_by_user).uniq - [sender, owner]
  end

  def create_mentions(names)
    User.by_mentioned(names).each do |user|
      user.mentions.create!(micropost: self)
    end
  end
end
