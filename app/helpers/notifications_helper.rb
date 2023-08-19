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
    when 'Relationship'
      user_url(notifiable.user, relationship_id: notifiable.id)
    when "Like"
      path_to_notifiable(notifiable.likeable)
    when 'Comment'
      path_to_notifiable(notifiable.commentable, "comment_#{notifiable.id}")
    else root_url
    end
  end
end
