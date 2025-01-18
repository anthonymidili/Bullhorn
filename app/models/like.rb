class Like < ApplicationRecord
  after_commit on: [ :create ] do
    NotifierJob.perform_later(self)
  end

  validates :user_id, uniqueness: { scope: [ :likeable_id, :likeable_type ] }

  belongs_to :user, inverse_of: :likes
  belongs_to :likeable, polymorphic: true
  has_many :notifications, as: :notifiable, dependent: :destroy
end
