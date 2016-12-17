class NotifierMailer < ApplicationMailer
  def alert_followers(to, from)
    @to_user = to
    @from_user = from
    mail( to: @to_user.email,
          subject: "#{@from_user.name} has a new micropost" )
  end
end
