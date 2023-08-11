class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
    :recoverable, :rememberable, :trackable, :validatable

  # Is following users relationships.
  has_many :relationships, dependent: :destroy
  has_many :following, through: :relationships, source: :followed
  # Followed by users relationships.
  has_many :reverse_relationships, foreign_key: 'followed_id', 
    class_name: 'Relationship', dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :user

  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile, reject_if: :all_blank, 
    allow_destroy: true

  has_one :receive_mail, dependent: :destroy

  has_many :phones, as: :callable, dependent: :destroy
  accepts_nested_attributes_for :phones, reject_if: :all_blank, 
    allow_destroy: true

  has_many :addresses, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :addresses, reject_if: :all_blank, 
    allow_destroy: true

  has_many :websites, dependent: :destroy
  accepts_nested_attributes_for :websites, reject_if: :all_blank, 
    allow_destroy: true

  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy

  has_many :invitations, dependent: :destroy
  has_many :events, through: :invitations
  has_many :events, dependent: :destroy
  has_many :notifications, foreign_key: 'recipient_id', dependent: :destroy
  has_many :comments, foreign_key: 'created_by_id', dependent: :destroy

  has_one_attached :avatar

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :avatar, file_content_type: {
    allow: ['image/jpg', 'image/jpeg', 'image/gif', 'image/png']
  }, if: -> { avatar.attached? }

  def self.search_by(term)
    where(
      "first_name ILIKE :search
      OR last_name ILIKE :search
      OR username ILIKE :search
      OR first_name || \' \' || last_name ILIKE :search
      OR last_name || \' \' || first_name ILIKE :search
      OR username || \' \' || first_name || \' \' || last_name ILIKE :search
      OR username || \' - \' || first_name || \' \' || last_name ILIKE :search",
      search: "%#{term}%"
    )
  end

  def self.search_results
    all.map do |user|
      [user.username, user.full_name].compact.join(" - ")
    end
  end

  scope :by_username, -> { order(username: :asc) }
  scope :by_admin, -> { where(is_admin: true) }
  scope :by_other_user, -> { where(is_admin: false) }
  # scope :by_accepts_email, -> { where(receive_email: true) }
  scope :all_but_current, -> (current_user) { where.not(id: current_user) }

  def relevant_events
    user_ids = following_ids << id
    Event.where(user: user_ids)
  end
  
  def full_name
    if first_name.present? || last_name.present?
      [first_name, last_name].join(' ')
    else
      nil
    end
  end

  def following?(user)
    relationships.find_by(followed: user)
  end

  def has_liked?(likeable)
    likes.find_by(likeable_type: likeable.class.name, likeable_id: likeable.id)
  end
end
