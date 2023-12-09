class Message < ApplicationRecord
  after_commit on: [:create] do
    NotifierJob.perform_later(self)
  end

  has_rich_text :body

  belongs_to :direct
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'
  
  has_many :notifications, as: :notifiable, dependent: :destroy

  # validates :body, presence: true
  
  default_scope { order(created_at: :desc) }
end
