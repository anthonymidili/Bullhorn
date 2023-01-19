class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile, reject_if: :all_blank, allow_destroy: true

  has_one :receive_mail, dependent: :destroy

  has_many :phones, as: :callable, dependent: :destroy
  accepts_nested_attributes_for :phones, reject_if: :all_blank, allow_destroy: true

  has_many :addresses, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :addresses, reject_if: :all_blank, allow_destroy: true

  has_many :websites, dependent: :destroy
  accepts_nested_attributes_for :websites, reject_if: :all_blank, allow_destroy: true

  has_many :posts, dependent: :destroy

  has_many :invitations, dependent: :destroy
  has_many :events, through: :invitations
  has_many :events, dependent: :destroy
  has_many :notifications, foreign_key: 'recipient_id', dependent: :destroy
  has_many :comments, foreign_key: 'created_by_id', dependent: :destroy

  has_one_attached :avatar

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :avatar, file_content_type: {
    allow: ['image/jpg', 'image/jpeg', 'image/gif', 'image/png']
  }, if: -> { avatar.attached? }

  scope :search_by, -> (term) {
    where("first_name ILIKE :search
      OR last_name ILIKE :search
      OR first_name || \' \' || last_name ILIKE :search
      OR last_name || \' \' || first_name ILIKE :search",
      search: "%#{term}%")
    }

  scope :by_first_name, -> { order(first_name: :asc) }
  scope :by_admin, -> { where(is_admin: true) }
  scope :by_other_user, -> { where(is_admin: false) }
  # scope :by_accepts_email, -> { where(receive_email: true) }
  scope :all_but_current, -> (current_user) { where.not(id: current_user) }

  def full_name
    [first_name, last_name].join(' ')
  end
end
