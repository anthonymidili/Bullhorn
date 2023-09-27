class InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :set_invitation, only: [:update]

  def create
    @invitation = current_user.invitations.build(invitation_params)
    @invitation.event = @event

    respond_to do |format|
      if @invitation.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(helpers.dom_id(@event, "response"), 
            partial: "events/response", locals: { event: @event })
          ]
        end
        format.html { redirect_to @event, notice: 'Invitation was successfully created.' }
      else
        format.html { redirect_to @event, notice: 'Invitation was not successfully created.' }
      end
    end
  end

  def update
    respond_to do |format|
      if @invitation.update(invitation_params)
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(helpers.dom_id(@event, "response"), 
            partial: "events/response", locals: { event: @event })
          ]
        end
        format.html { redirect_to @event, notice: 'Invitation was successfully updated.' }
      else
        format.html { redirect_to @event, notice: 'Invitation was not successfully updated.' }
      end
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
