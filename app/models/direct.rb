class Direct < ApplicationRecord
  has_many :conversations, dependent: :destroy
  has_many :users, through: :conversations
  has_many :messages, dependent: :destroy
end
