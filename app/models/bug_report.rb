class BugReport < ApplicationRecord
  belongs_to :user, optional: true

  validates :subject, presence: true
  validates :body, presence: true

  scope :by_created_at, -> { order(created_at: :asc) }
end
