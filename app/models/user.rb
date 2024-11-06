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

  # Notifications recieved.
  has_many :notifications, foreign_key: 'recipient_id', dependent: :destroy
  # Notifications sent.
  has_many :sent_notifications, foreign_key: "notifier_id",
  class_name: "Notification", dependent: :destroy

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
  has_many :reposts, dependent: :destroy
  has_many :invitations, dependent: :destroy
  has_many :events, through: :invitations
  has_many :events, dependent: :destroy
  has_many :comments, foreign_key: 'created_by_id', dependent: :destroy
  has_many :bug_reports, dependent: :destroy
  has_many :conversations, dependent: :destroy
  has_many :directs, through: :conversations
  has_many :messages, foreign_key: 'created_by_id', dependent: :destroy

  has_one_attached :avatar

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validate :is_image_type

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
  scope :by_unconfirmed, -> { 
    where(confirmed_at: nil).
    where("confirmation_sent_at < :date", date: (DateTime.current - 1.day)) 
  }

  # Only show events user created or was invited to.
  def relevant_events
    Event.joins(:invitations).where(invitations: { user: self })
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

  def has_reposted?(post)
    reposts.find_by(reposted_id: post.id)
  end

  # All user relationships both followers and following.
  def all_relationships
    (followers + following).uniq
  end

  def self.users_online
    users_online = Kredis.unique_list "users_online"
    where(id: users_online.elements)
  end

  def online?
    users_online_ids = User.users_online.ids
    users_online_ids.include?(id)
  end

  def find_or_init_direct_message(user, params)
    # Find all directs that both users are in together and reject the directs
    # that have move than 2 users attached.
    existing_directs = (self.directs & user.directs).reject { |d| d.users.length > 2 }
    personal_direct = existing_directs.first
    if personal_direct
      return personal_direct
    else
      # Build a direct object for the current user.
      new_direct = self.directs.build(params)
      # Add profile user to newly built direct.
      new_direct.users << user
      return new_direct
    end
  end

private

  def is_image_type
    if avatar.attached? && !avatar.content_type.in?(['image/jpg', 'image/jpeg', 'image/gif', 'image/png'])
      avatar.purge # delete the uploaded file
      errors.add(:avatar, 'Must be an image file.')
    end
  end
end
