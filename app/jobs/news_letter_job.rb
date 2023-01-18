class NewsLetterJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 2

  def perform(id)
    news_letter = NewsLetter.find_by(id: id)
    recipients_emails = User.pluck(:email) + AdditionalRecipient.pluck(:email)

    # if news_letter && news_letter.is_sent == false
    NewActivityMailer.latest_news_letter(
      recipients_emails,
      news_letter
    ).deliver_now

    news_letter.update_attribute(:is_sent, true)
    # end
  end
end
