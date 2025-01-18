class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("DEFAULT_MAILER_SENDER") { "to@example.org" }
  layout "mailer"
end
