class Hashtag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :posts, through: :taggings, source: :taggable, source_type: "Post"
  has_many :comments, through: :taggings, source: :taggable, source_type: "Comment"

  validates :name, presence: true, uniqueness: { case_sensitive: false },
                   format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers, and underscores" }

  before_validation :strip_hash_symbol

  def to_param
    name
  end

  def self.search(term)
    where("name ILIKE ?", "%#{term}%").order(name: :asc)
  end

  private

  def strip_hash_symbol
    self.name = name.to_s.sub(/\A#/, "").strip if name.present?
  end
end
