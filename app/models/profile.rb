class Profile < ApplicationRecord
  belongs_to :user

  def occupation
    [workplace, position].select(&:present?).join(' - ')
  end
end
