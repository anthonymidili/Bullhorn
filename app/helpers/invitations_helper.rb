module InvitationsHelper
  def find_or_init_invitation(event)
    current_user.invitations.find_or_initialize_by(event_id: event.id)
  end

  def status_icon(status)
    case status
    when 'going'
      raw('<i class="fa-solid fa-circle-check" style="color: green;"></i>')
    when 'maybe'
      raw('<i class="fa-solid fa-question-circle" style="color: #ffa933;"></i>')
    when 'cant_go'
      raw('<i class="fa-solid fa-times-circle" style="color: red;"></i>')
    else
      ''
    end
  end
end
