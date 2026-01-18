class OnlineChannel < Turbo::StreamsChannel
  def subscribed
    super
    return unless current_user
    mark_online
  end

  def unsubscribed
    return unless current_user
    mark_offline
  end

private

  def mark_online
    users_online = Kredis.unique_list "users_online"
    users_online << current_user.id
    broadcast_status
  end

  def mark_offline
    users_online = Kredis.unique_list "users_online"
    users_online.remove current_user.id
    broadcast_status
  end

  def broadcast_status
    Turbo::StreamsChannel.broadcast_update_later_to(
      verified_stream_name_from_params,
      target: "user_#{current_user.id}_status",
      partial: "users/status",
      locals: { user: current_user }
    )
  end
end
