class MarkOfflineJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    # Check if user is still online (may have reconnected)
    users_online = Kredis.unique_list "users_online"
    return if users_online.elements.include?(user.id.to_s)

    # Mark user as offline only if they're not in the online list
    users_online.remove user.id

    # Broadcast status update
    Turbo::StreamsChannel.broadcast_update_to(
      "online_users",
      target: "user_#{user.id}_status",
      partial: "users/status",
      locals: { user: user }
    )
  end
end
