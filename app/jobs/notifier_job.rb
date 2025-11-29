class NotifierJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3

  # `notifier_class` is injectable for easier testing; defaults to CreateNotifications
  def perform(notifiable, notifier_class = CreateNotifications)
    notifier_class.new(notifiable)
  end
end
