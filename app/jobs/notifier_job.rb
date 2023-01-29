class NotifierJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3

  def perform(notifiable)
    CreateNotifications.new(notifiable)
  end
end
