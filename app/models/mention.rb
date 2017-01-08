class Mention < ApplicationRecord
  belongs_to :user, inverse_of: :mentions
  belongs_to :micropost, inverse_of: :mentions
end
