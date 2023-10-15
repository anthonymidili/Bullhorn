class CreateNotifications
  def initialize(notifiable)
    notifier = notifiable.send(comment_or_other_user(notifiable))
    recipients = get_recipients(notifiable)
    recipients.each do |recipient|
      if notifiable && recipient && notifier
        mail_notification(notifiable, recipient, notifier)
        create_notification(notifiable, recipient, notifier)
      end
    end
  end

private

  def get_recipients(notifiable)
    case notifiable.class.name
    when "Comment"
      recipients = notifiable.commentable.comments.map(&:created_by)
      recipients << notifiable.commentable.user
      if notifiable.commentable.class.name == "Event"
        recipients + notifiable.commentable.invitations.by_going_maybe.map(&:user)
      end
      recipients = (recipients - [ notifiable.created_by ]).uniq
    when "Relationship"
      [ notifiable.followed ]
    when "Post"
      notifiable.user.followers
    when "Event"
      notifiable.users - [ notifiable.user ]
    when "Like"
      [ notifiable.likeable.send(comment_or_other_user(notifiable.likeable)) ] - [ notifiable.user ]
    else
      notifiable.user.all_relationships - [ notifiable.user ]
    end
  end

  def mail_notification(notifiable, recipient, notifier)
    r_r_m = recipient.receive_mail || recipient.create_receive_mail
    if mail_permitted?(notifiable, recipient) && !recipient.online? &&
    (!recipient.notifications.has_recent_unread? ||
    r_r_m.recent_mail_timed_out?)
      NewActivityMailer.new_activity(
        recipient,
        notifier,
        notifiable,
        action_statement(notifiable)
      ).deliver_now
      r_r_m.update_last_mail_received
    end
  end
  
  def create_notification(notifiable, recipient, notifier)
    notification = 
      notifiable.notifications.create(
        recipient: recipient,
        notifier: notifier,
        action: action_statement(notifiable)
      )
    
    Turbo::StreamsChannel.broadcast_render_later_to(
      "notifications_channel:#{recipient.to_gid_param}",
      partial: "notifications/new",
      locals: { user: recipient, notification: notification }
    )
  end

  def comment_or_other_user(notifiable)
    if notifiable.class.name == 'Comment'
      'created_by'
    else
      'user'
    end
  end

  def mail_permitted?(notifiable, recipient)
    if recipient.receive_mail
      recipient.receive_mail.send("for_new_#{notifiable.class.name.downcase.pluralize}")
    else
      true
    end
  end

  def action_statement(notifiable)
    case notifiable.class.name
    when 'Post'
      "Added a New Post - #{notifiable.body.truncate(40)}"
    when 'Event'
      "Created a New Event - #{notifiable.name}"
    when 'Relationship'
      'Started Following You'
    when 'Comment'
      "Commented on
      #{commentable_action_statement(notifiable.commentable)}
      (Comment - #{notifiable.body.truncate(40)})"
    when "Like"
      "Liked your #{likeable_action_statement(notifiable.likeable)}"
    else
      'Posted Something New'
    end
  end

  def commentable_action_statement(commentable)
    case commentable.class.name
    when "Post"
      "a Post - #{commentable.body.truncate(40)}"
    when "Event"
      "an Event - #{commentable.name}"
    else
      "Commented on something"
    end
  end

  def likeable_action_statement(likeable)
    case likeable.class.name
    when "Post"
      "Post - #{likeable.body.truncate(40)}"
    when "Comment"
      "Comment - #{likeable.body.truncate(40)}"
    else
      "Liked something"
    end
  end
end
