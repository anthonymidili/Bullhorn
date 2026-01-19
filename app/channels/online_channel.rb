class OnlineChannel < Turbo::StreamsChannel
  OFFLINE_DELAY = 3.seconds

  def subscribed
    super
    return unless current_user
    mark_online
  end

  def unsubscribed
    return unless current_user
    schedule_mark_offline
  end

private

  def mark_online
    users_online = Kredis.unique_list "users_online"
    users_online << current_user.id
    broadcast_status
  end

  def schedule_mark_offline
    # Delay marking offline to prevent flickering during quick navigation
    MarkOfflineJob.set(wait: OFFLINE_DELAY).perform_later(current_user.id)
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
