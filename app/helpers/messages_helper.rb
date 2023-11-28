module MessagesHelper
  def current_or_others(user)
    correct_user?(user) ?  "current" : "others"
  end
end
