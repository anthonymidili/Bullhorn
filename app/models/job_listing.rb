class JobListing < ApplicationRecord
  before_validation :set_user, on: [:create]
  before_validation :set_duration_ends_at
  after_commit on: [:create] do
    NotifierJob.perform_later(self)
  end

  belongs_to :user
  belongs_to :company

  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :title, presence: true
  validates :classification, presence: true
  validates :status, presence: true
  validates :comp_min, presence: { if: :comp_per? }
  validates :comp_max, presence: { if: :comp_per? }
  validates :comp_per, presence: true,
  if: Proc.new { |job_listing| job_listing.comp_min? || job_listing.comp_max? }
  validates :description, presence: true
  validates :apply_email, presence: true
  validates :dur_interval, numericality: true
  validates :dur_cal_type, presence: true

  scope :search_by, -> (term) {
    where("title ILIKE :search",
      search: "%#{term}%")
    }

  attr_writer :dur_interval, :dur_cal_type

  def self.by_currently_listed
    where('duration_ends_at > :today', today: Date.current).
    where(is_listed: true)
  end

  def currently_listed?
    duration_ends_at > Date.current && is_listed
  end

  # attr_reader
  def dur_interval
    @dur_interval ||=
      if duration_ends_at
        duration = (duration_ends_at - Date.current).to_i
        duration < 0 ? 14 : duration
      end
  end

  # attr_reader
  def dur_cal_type
    @dur_cal_type ||=
      'days' if duration_ends_at
  end

  def self.select_classification_options
    [
      ['Employee', 'employee'],
      ['Temporary/Contract', 'temporary'],
      ['Intern', 'intern'],
      ['Seasonal', 'seasonal']
    ]
  end

  def self.select_status_options
    [
      ['Full Time', 'full_time'],
      ['Part Time', 'part_time'],
      ['Per Diem', 'per_diem']
    ]
  end

  def self.select_comp_per_options
    [
      ['Year', 'year'],
      ['Hour', 'hour'],
      ['Week', 'week'],
      ['Month', 'month'],
      ['Biweekly', 'biweekly']
    ]
  end

  def self.select_duration_options
    [
      ['Days', 'days'],
      ['Weeks', 'weeks'],
      ['Months', 'months']
    ]
  end

  def salary
    min = ActiveSupport::NumberHelper.number_to_currency(comp_min)
    max = ActiveSupport::NumberHelper.number_to_currency(comp_max)
    "#{min} - #{max} / #{comp_per}" if comp_min && comp_max
  end

  include ReadNotifications
  # def read_user_notifications(current_user)
  #   notifications.by_unread.where(recipient: current_user).
  #   update_all(is_read: true)
  #   read_comment_notifications(current_user)
  # end
  # def read_comment_notifications(current_user)
  #   comments.each do |comment|
  #     comment.notifications.by_unread.where(recipient: current_user).
  #     update_all(is_read: true)
  #   end
  # end

private

  def set_user
    self.user = company.user
  end

  def set_duration_ends_at
    if ['days', 'weeks', 'months'].include?(@dur_cal_type)
      end_date = Date.current + @dur_interval.to_i.send(@dur_cal_type)
      self.duration_ends_at = end_date
    end
  end
end
