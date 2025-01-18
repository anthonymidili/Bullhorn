class OnlineChannel < Turbo::StreamsChannel
  def subscribed
    super
    return unless current_user
    users_online = Kredis.unique_list "users_online"
    users_online << current_user.id
    # users_online.elements
    # users_online.elements.count
    Turbo::StreamsChannel.broadcast_update_later_to(
      verified_stream_name_from_params,
      target: "user_#{current_user.id}_status",
      partial: "users/status",
      locals: { user: current_user }
    )
  end

  def unsubscribed
    return unless current_user
    users_online = Kredis.unique_list "users_online"
    users_online.remove current_user.id
    Turbo::StreamsChannel.broadcast_update_later_to(
      verified_stream_name_from_params,
      target: "user_#{current_user.id}_status",
      partial: "users/status",
      locals: { user: current_user }
    )
  end
end
