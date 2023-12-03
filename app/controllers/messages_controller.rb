class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_direct
  before_action :set_message, only: %i[ show edit update destroy ]
  before_action :deny_access!, only: [:edit, :update, :destroy],
  unless:  -> { correct_user?(@message.created_by) }

  def show
    # Calls messages/message_frame to include current_user.
  end

  # GET /messages or /messages.json
  # GET /messages/new
  def new
    @message = @direct.messages.build
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages or /messages.json
  def create
    @message = @direct.messages.build(message_params)
    @message.created_by = current_user

    respond_to do |format|
      if @message.save
        @message.broadcast_prepend_to(@direct, target: "messages", partial: "messages/message_frame", 
        locals: { message: @message })
        format.turbo_stream do
          render turbo_stream: [
            # turbo_stream.prepend("messages", partial: "messages/message", 
            # locals: { message: @message }),
            turbo_stream.replace("form_message", partial: "messages/form", 
            locals: { direct: @direct, message: @direct.messages.build })
          ]
        end
        format.html { redirect_to direct_url(@direct), notice: "Message was successfully created." }
        format.json { render :show, status: :created, location: @direct }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("form_message", partial: "messages/form", 
            locals: { direct: @direct, message: @message })
          ]
        end
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1 or /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        @message.broadcast_replace_to(@direct, target: @message, partial: "messages/message_frame", 
        locals: { message: @message })
        format.turbo_stream do
          render turbo_stream: [
            # turbo_stream.replace(@message, partial: "messages/message", 
            # locals: { message: @message })
          ]
        end
        format.html { redirect_to direct_url(@direct), notice: "Message was successfully updated." }
        format.json { render :show, status: :ok, location: @direct }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(helpers.dom_id(@message, "form"), 
            partial: "messages/form",
            locals: { direct: @direct, message: @message })
          ]
        end
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1 or /messages/1.json
  def destroy
    @message.destroy

    respond_to do |format|
      @message.broadcast_remove_to(@direct, target: @message)
      format.turbo_stream { 
        # render turbo_stream: turbo_stream.remove(@message) 
      }
      format.html { redirect_to messages_url, notice: "Message was successfully destroyed." }
      format.json { head :no_content }
    end
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_direct
    @direct = current_user.directs.find_by(id: params[:direct_id])
  end

  def set_message
    @message = @direct.messages.find_by(id: params[:id])
  end

  # Only allow a list of trusted parameters through.
  def message_params
    params.require(:message).permit(:body)
  end
end
