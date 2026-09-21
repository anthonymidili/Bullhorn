class Tagging < ApplicationRecord
  belongs_to :hashtag
  belongs_to :taggable, polymorphic: true

  validates :hashtag_id, uniqueness: { scope: [:taggable_type, :taggable_id] }
end
