class Message < ApplicationRecord
  belongs_to :direct
  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_id'

  validates :body, presence: true
  
  default_scope { order(created_at: :desc) }
end
