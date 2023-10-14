class OnlineChannel < Turbo::StreamsChannel
  def subscribed
    super
    return unless current_user
    current_user.update_attribute(:online, true)
  end

  def unsubscribed
    return unless current_user
    current_user.update_attribute(:online, false)
  end
end
