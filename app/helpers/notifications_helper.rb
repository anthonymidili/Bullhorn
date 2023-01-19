module NotificationsHelper
  def set_as_read!
    notifiable = self.controller_name.classify.constantize.find_by(id: params[:id])
    notifiable.read_user_notifications(current_user)
  end

  def path_to_notifiable(notifiable, anchor = nil)
    case notifiable.class.name
    when 'Post'
      post_url(notifiable, anchor: anchor)
    when 'Event'
      event_url(notifiable, anchor: anchor)
    when 'Comment'
      path_to_notifiable(notifiable.commentable, "comment_#{notifiable.id}")
    end
  end
end