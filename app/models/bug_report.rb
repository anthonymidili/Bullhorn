class BugReport < ApplicationRecord
  belongs_to :user, optional: true

  validates :subject, presence: true
  validates :body, presence: true

  scope :by_created_at, -> { order(created_at: :asc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_status_open, -> { where.not(status: "closed") }

  def status_options
    [ [ "New", "new" ], [ "Checking", "checking" ], [ "Closed", "closed" ] ]
  end
end
