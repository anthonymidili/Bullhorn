class AvatarUser < ApplicationRecord
  belongs_to :user, inverse_of: :avatar_user
  belongs_to :photo, inverse_of: :avatar_user
end