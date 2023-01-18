class Article < ApplicationRecord
  belongs_to :news_letter

  has_one_attached :image

  validates :title, presence: true
  validates :content, presence: true
  validates :image, file_content_type: {
    allow: ['image/jpg', 'image/jpeg', 'image/gif', 'image/png']
  }, if: -> { image.attached? }

  default_scope { order(created_at: :asc) }
end
