class Conversation < ApplicationRecord
  belongs_to :user, inverse_of: :conversations
  belongs_to :direct, inverse_of: :conversations
end
