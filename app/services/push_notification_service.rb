class PushNotificationService
  def self.send_notification(user, title:, body:, url: "/")
    return unless user.push_subscriptions.any?

    message = {
      title: title,
      body: body,
      url: url,
      icon: "/icon-192.png",
      badge: "/icon-192.png"
    }.to_json

    vapid_keys = {
      public_key: Rails.application.credentials.dig(:vapid, :public_key),
      private_key: Rails.application.credentials.dig(:vapid, :private_key)
    }

    user.push_subscriptions.find_each do |subscription|
      begin
        WebPush.payload_send(
          message: message,
          endpoint: subscription.endpoint,
          p256dh: subscription.p256dh,
          auth: subscription.auth,
          ttl: 24 * 60 * 60, # 24 hours
          vapid: vapid_keys
        )
        Rails.logger.info "Push notification sent to user #{user.id}"
      rescue WebPush::InvalidSubscription, WebPush::ExpiredSubscription => e
        Rails.logger.warn "Subscription expired or invalid for user #{user.id}: #{e.message}"
        subscription.destroy
      rescue => e
        Rails.logger.error "Failed to send push notification to user #{user.id}: #{e.message}"
      end
    end
  end

  def self.send_to_multiple_users(users, title:, body:, url: "/")
    users.each do |user|
      send_notification(user, title: title, body: body, url: url)
    end
  end
end
