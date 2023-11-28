class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_direct
  before_action :set_message, only: %i[ edit update destroy ]

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
        format.html { redirect_to direct_url(@direct), notice: "Message was successfully created." }
        format.json { render :show, status: :created, location: @direct }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1 or /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to direct_url(@direct), notice: "Message was successfully updated." }
        format.json { render :show, status: :ok, location: @direct }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1 or /messages/1.json
  def destroy
    @message.destroy

    respond_to do |format|
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
