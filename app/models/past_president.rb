class PastPresident < ApplicationRecord
  has_one_attached :avatar

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :term_order, numericality: true
  validates :term_started_at, presence: true
  # validates :bio, presence: true
  validates :avatar, file_content_type: {
    allow: ['image/jpg', 'image/jpeg', 'image/gif', 'image/png']
  }, if: -> { avatar.attached? }

  default_scope  { order(term_started_at: :asc) }

  def full_name
    [first_name, last_name].join(' ')
  end
end
