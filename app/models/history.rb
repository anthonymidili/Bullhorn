class History < ApplicationRecord
  has_many_attached :images

  validates :content, presence: true
  validates :images, file_content_type: {
    allow: ['image/jpg', 'image/jpeg', 'image/gif', 'image/png']
  }, if: -> { images.attached? }
end
