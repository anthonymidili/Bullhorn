class TurnNotificationsOn < ActiveRecord::Migration[6.0]
  ReceiveMail.all.update_all(
    for_new_posts: true,
    for_new_events: true,
    for_new_job_listings: true,
    for_new_comments: true
  )
end
