class Industry < ApplicationRecord
  has_many :companies

  validates :name, presence: true

  scope :search_by, -> (term) {
    where("name ILIKE :search", search: "%#{term}%")
  }
end
