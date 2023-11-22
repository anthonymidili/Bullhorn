class Direct < ApplicationRecord
  has_many :conversations, dependent: :destroy
  has_many :users, through: :conversations
end
