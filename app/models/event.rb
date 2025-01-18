class Event < ApplicationRecord
  after_commit :set_as_going, on: [ :create ]
  after_commit on: [ :create ] do
    NotifierJob.perform_later(self)
  end

  belongs_to :user

  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address, reject_if: :all_blank, allow_destroy: true

  has_one_attached :image
  has_many :invitations, dependent: :destroy
  has_many :users, through: :invitations
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :future_start_date?
  validate :ends_before_it_starts?
  validate :is_image_type

  default_scope  { order(start_date: :asc) }

  # Getter to set start date on form
  def start_date
    self[:start_date] ||= Time.current + 1.hour
  end

  # Getter to set end date on form
  def end_date
    self[:end_date] ||= Time.current + 3.hours
  end

  def self.in_the_future
    time_range = Date.current.beginning_of_day..(Date.current + 2.years).end_of_day
    where(end_date: time_range)
  end

  def self.from_the_past
    time_range = (Date.current - 2.years).beginning_of_day..Date.current.end_of_day
    where(end_date: time_range).where.not(id: self.in_the_future.ids)
  end

  def self.future_and_past
    time_range = (Date.current - 2.years).beginning_of_day..(Date.current + 2.years).end_of_day
    where(end_date: time_range)
  end

  include ReadNotifications
# def read_user_notifications(current_user)
#   self.notifications.by_unread.where(recipient: current_user).
#   update_all(is_read: true)
#   read_comment_notifications(current_user) if self.try(:comments)
#   read_like_notifications(current_user) if self.try(:likes)
# end

private

  def set_as_going
    creators_invitation = self.invitations.find_or_create_by(user: self.user)
    creators_invitation.update_attribute(:status, "going")
  end

  def future_start_date?
    unless start_date > Time.current
      errors.add(:start_date, "must be in the future.")
    end
  end

  def ends_before_it_starts?
    unless end_date > start_date
      errors.add(:end_date, "must be greater than the start date.")
    end
  end

  def is_image_type
    if image.attached? && !image.content_type.in?([ "image/jpg", "image/jpeg", "image/gif", "image/png" ])
      image.purge # delete the uploaded file
      errors.add(:image, "Must be an image file.")
    end
  end
end
