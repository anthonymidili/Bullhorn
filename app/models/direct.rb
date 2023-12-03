class Direct < ApplicationRecord
  has_many :conversations, dependent: :destroy
  has_many :users, through: :conversations
  has_many :messages, dependent: :destroy

  validate :user_selected

private

  def user_selected
    errors.add(:base, 'Search and select a user to message.') unless users.length > 0
  end
end
