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
    if notifiable.class.name == "Comment"
      recipients = notifiable.commentable.comments.map(&:created_by)
      recipients << notifiable.commentable.user
      recipients = (recipients - [notifiable.created_by]).uniq
    elsif notifiable.class.name == "Relationship"
      [ notifiable.followed ]
    elsif notifiable.class.name == "Post" || notifiable.class.name == "Event"
      notifiable.user.followers
    else
      User.all_but_current(notifiable.user)
    end
  end

  def mail_notification(notifiable, recipient, notifier)
    if mail_permitted?(notifiable, recipient) &&
    !recipient.notifications.has_recent_unread?
      NewActivityMailer.new_activity(
        recipient,
        notifier,
        notifiable
      ).deliver_now
    end
  end
  
  def create_notification(notifiable, recipient, notifier)
    notification = 
      notifiable.notifications.create(
        recipient: recipient,
        notifier: notifier,
        action: action_statement(notifiable)
      )
    
    NotifierChannel.broadcast_to recipient, 
    unread_notifications_count: recipient.notifications.recent_unread_count,
    notification_partial: render_notification(notification)
  end

  def render_notification(notification)
    renderer = ApplicationController.renderer.new(
      http_host: ENV.fetch("DEFAULT_URL_HOST", "localhost:3000"),
      https: false # false so image is not broken
    )

    renderer.render partial: 'notifications/notification',
    locals: { notification: notification }
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
      'added a new post'
    when 'Event'
      'created a new event'
    when 'Relationship'
      'started following you'
    when 'Comment'
      commentable_class_name = notifiable.commentable.class.name.downcase
      "commented on
      #{an_or_a(commentable_class_name)}
      #{commentable_class_name}"
    else
      'posted something new'
    end
  end

  def an_or_a(commentable_class_name)
    commentable_class_name == 'event' ? 'an' : 'a'
  end
end
