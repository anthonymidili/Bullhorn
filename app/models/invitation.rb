class Invitation < ApplicationRecord
  belongs_to :user, inverse_of: :invitations
  belongs_to :event, inverse_of: :invitations

  scope :responce, -> (status) { where(status: status) }
  scope :by_going_maybe, -> { where.not(status: 'cant_go') }
  scope :user_status, -> (user) { find_by(user_id: user).try(:status) }
end
