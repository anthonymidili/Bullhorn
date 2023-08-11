class Like < ApplicationRecord
  validates :user_id, uniqueness: { scope: [ :likeable_id, :likeable_type ] }

  belongs_to :user, inverse_of: :likes
  belongs_to :likeable, polymorphic: true
end
