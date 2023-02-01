class Relationship < ApplicationRecord
  belongs_to :user, foreign_key: :user_id, 
    class_name: 'User', inverse_of: :relationships
  belongs_to :followed, foreign_key: :followed_id, 
    class_name: 'User', inverse_of: :relationships
end
