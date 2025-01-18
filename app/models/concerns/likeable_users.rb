module LikeableUsers
  extend ActiveSupport::Concern

  def users_who_liked
    users = self.likes.pluck(:user_id)
    User.where(id: users)
  end
end
