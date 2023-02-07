class NewActivityMailer < ApplicationMailer
  # requires 'notifications_helper' and includes NotificationsHelper
  helper :notifications

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.new_activity_mailer.new_post.subject
  #
  def new_activity(to, from, notifiable)
    @to_user = to
    @from_user = from
    @notifiable = notifiable

    attachments.inline['bullhorn.png'] = File.read("#{Rails.root}/app/assets/images/bullhorn.png")

    mail to: @to_user.email,
    subject: "New Activity - #{@from_user.full_name} has made a New #{@notifiable.class.name}"
  end
end
