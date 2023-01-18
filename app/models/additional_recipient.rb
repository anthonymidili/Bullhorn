class AdditionalRecipient < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validate :no_duplicate_user

private

  def no_duplicate_user
    if User.pluck(:email).include?(email)
      errors.add(:email, 'has already been taken.')
    end
  end
end
