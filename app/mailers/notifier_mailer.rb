class NotifierMailer < ApplicationMailer
  def alert_followers(to, from)
    @to_user = to
    @from_user = from
    mail( to: @to_user.email,
          subject: "#{@from_user.name} has a new micropost" )
  end

  def alert_post_owner(to, from, micropost)
    @to_user = to
    @from_user = from
    @micropost = micropost
    mail( to: @to_user.email,
          subject: "#{@from_user.name} commented on your micropost" )
  end

  def alert_commenters(to, from, micropost)
    @to_user = to
    @from_user = from
    @micropost = micropost
    mail( to: @to_user.email,
          subject: "#{@from_user.name} commented on a micropost" )
  end
end
