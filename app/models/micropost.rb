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

  scope :from_users_followed_by, -> (user) { followed_by(user) }

  def commenters(sender, owner)
    comments.map(&:created_by_user).uniq - [sender, owner]
  end

  def create_mentions(users_mentioned)
    users_names = users_mentioned.split(', ')
    users_names.each do |name|
      user = User.find_by(name: name)
      user.mentions.create(micropost: self) if user
    end
  end

private

  def self.followed_by(user)
    followed_user_ids = user.relationships.pluck(:followed_id).uniq
    own_and_followers = where(user_id: followed_user_ids << user.id)
    mentioned_in = where(id: user.mentions.pluck(:micropost_id))
    own_and_followers.or(mentioned_in)
  end
end
