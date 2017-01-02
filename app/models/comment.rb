class Comment < ApplicationRecord
  belongs_to :created_by_user, foreign_key: 'created_by_user_id', class_name: 'User'
  belongs_to :commentable, polymorphic: true
  has_many :comments, as: :commentable, dependent: :destroy

  validates :content, presence: true

  default_scope { order(created_at: 'ASC') }
end
