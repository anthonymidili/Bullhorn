class Notification < ApplicationRecord
  belongs_to :recipient, class_name: 'User', foreign_key: 'recipient_id'
  belongs_to :notifier, class_name: 'User', foreign_key: 'notifier_id'
  belongs_to :notifiable, polymorphic: true

  default_scope  { order(created_at: :desc) }
  scope :by_unread, -> { where(is_read: false) }

  def self.recent
    time_range = (Time.current - 1.week)..Time.current
    where(created_at: time_range)
  end

  def self.earlier
    time_range = (Time.current - 2.months)..(Time.current - 1.week)
    where(created_at: time_range)
  end

  def self.recent_unread_count
    recent.by_unread.count
  end

  def self.has_recent_unread?
    recent_unread_count != 0
  end
end
