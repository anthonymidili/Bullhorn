class Micropost < ApplicationRecord
  # attr_accessible :content
  belongs_to :user
  belongs_to :photo

  accepts_nested_attributes_for :photo, reject_if: :all_blank
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :mentions, dependent: :destroy
  has_many :users, through: :mentions

  validates :content, presence: true, length: {maximum: 1000}
  validates :user_id, presence: true

  default_scope { order(created_at: 'DESC') }

  scope :from_users_followed_by, -> (user) { followed_by(user) }

  def commenters(sender, owner)
    comments.map(&:created_by_user).uniq - [sender, owner]
  end

private

  def self.followed_by(user)
    followed_user_ids = %(SELECT followed_id FROM relationships WHERE follower_id = :user_id)
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", {user_id: user})
  end
end
