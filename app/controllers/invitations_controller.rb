class InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :set_invitation, only: [:update]

  def create
    @invitation = current_user.invitations.build(invitation_params)
    @invitation.event = @event

    if @invitation.save
      redirect_to @event, notice: 'Invitation was successfully created.'
    else
      redirect_to @event, notice: 'Invitation was not successfully created.'
    end
  end

  def update
    if @invitation.update(invitation_params)
      redirect_to @event, notice: 'Invitation was successfully updated.'
    else
      redirect_to @event, notice: 'Invitation was not successfully updated.'
    end
  end

private

  def set_event
    @event = Event.find_by(id: params[:event_id])
  end

  def set_invitation
    @invitation = current_user.invitations.find_by(id: params[:id])
  end

  def invitation_params
    params.require(:invitation).permit(:status)
  end
end
