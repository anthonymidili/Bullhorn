class Photo < ApplicationRecord
  belongs_to :user

  mount_uploader :image, ImageUploader

  scope :by_newest, -> { order(created_at: :desc) }
end
