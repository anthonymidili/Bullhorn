class NotifierJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3

  # `notifier_class` is injectable for easier testing;
  # defaults to CreateNotificationsService
  def perform(notifiable, notifier_class = CreateNotificationsService)
    notifier_class.new(notifiable)
  end
end
