class Comment < ApplicationRecord
  belongs_to :created_by_user, foreign_key: 'created_by_user_id', class_name: 'User'
  belongs_to :commentable, polymorphic: true
  has_many :comments, as: :commentable
end
