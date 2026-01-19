class CreateNotifications
  include Rails.application.routes.url_helpers

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
    when "Message"
      notifiable.direct.users - [ notifiable.created_by ]
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

    # Send push notification if user has subscriptions
    send_push_notification(notifiable, recipient, notifier)
  end

  def send_push_notification(notifiable, recipient, notifier)
    return unless recipient.push_subscriptions.any?
    return if recipient.online? # Only send push if user is offline

    PushNotificationService.send_notification(
      recipient,
      title: push_notification_title(notifiable, notifier),
      body: action_statement(notifiable),
      url: push_notification_url(notifiable)
    )
  end

  def push_notification_title(notifiable, notifier)
    notifier_name = notifier.username || notifier.full_name || "Someone"

    case notifiable.class.name
    when "Like"
      "#{notifier_name} liked your content"
    when "Comment"
      "#{notifier_name} commented"
    when "Relationship"
      "#{notifier_name} followed you"
    when "Post"
      notifiable.reposting ? "#{notifier_name} reshared a post" : "#{notifier_name} created a post"
    when "Event"
      "#{notifier_name} created an event"
    when "Message"
      "#{notifier_name} sent you a message"
    else
      "#{notifier_name} - BullhornXL"
    end
  end

  def push_notification_url(notifiable)
    case notifiable.class.name
    when "Relationship"
      user_url(notifiable.user_id)
    when "Post"
      post_url(notifiable)
    when "Event"
      event_url(notifiable)
    when "Comment"
      if notifiable.commentable_type == "Post"
        post_url(notifiable.commentable_id)
      elsif notifiable.commentable_type == "Event"
        event_url(notifiable.commentable_id)
      else
        root_url
      end
    when "Like"
      if notifiable.likeable_type == "Post"
        post_url(notifiable.likeable_id)
      elsif notifiable.likeable_type == "Comment"
        comment = Comment.find_by(id: notifiable.likeable_id)
        comment ? post_url(comment.post_id) : root_url
      else
        root_url
      end
    when "Message"
      direct_url(notifiable.direct_id, anchor: "footer")
    else
      root_url
    end
  end

  def comment_or_other_user(notifiable)
    if notifiable.class.name == "Comment" || notifiable.class.name == "Message"
      "created_by"
    else
      "user"
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
    when "Post"
      if notifiable.reposting
        "Reposted
        #{notifiable.reposting.user.username}
        Post - #{notifiable.reposting.body.to_plain_text.truncate(40) if notifiable.reposting.body}"
      else
        "Added a New Post - #{notifiable.body.to_plain_text.truncate(40) if notifiable.body}"
      end
    when "Event"
      "Created a New Event - #{notifiable.name}"
    when "Relationship"
      "Started Following You"
    when "Comment"
      "Commented on
      #{commentable_action_statement(notifiable.commentable)}
      (Comment - #{notifiable.body.truncate(40) if notifiable.body})"
    when "Like"
      "Liked your #{likeable_action_statement(notifiable.likeable)}"
    when "Message"
      "Direct Messaged - #{notifiable.body.to_plain_text.truncate(40) if notifiable.body}"
    else
      "Posted Something New"
    end
  end

  def commentable_action_statement(commentable)
    case commentable.class.name
    when "Post"
      "a Post - #{commentable.body.to_plain_text.truncate(40) if commentable.body}"
    when "Event"
      "an Event - #{commentable.name}"
    else
      "Commented on something"
    end
  end

  def likeable_action_statement(likeable)
    case likeable.class.name
    when "Post"
      "Post - #{likeable.body.to_plain_text.truncate(40) if likeable.body}"
    when "Comment"
      "Comment - #{likeable.body.truncate(40) if likeable.body}"
    else
      "Liked something"
    end
  end
end
