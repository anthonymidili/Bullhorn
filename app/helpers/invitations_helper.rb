module InvitationsHelper
  def find_or_init_invitation(event)
    current_user.invitations.find_or_initialize_by(event_id: event.id)
  end

  def status_icon(status)
    case status
    when 'going'
      fa_icon 'check-circle', style: 'color: green'
    when 'maybe'
      fa_icon 'question-circle', style: 'color: #ffa933;'
    else
      fa_icon 'times-circle', style: 'color: red'
    end
  end
end
