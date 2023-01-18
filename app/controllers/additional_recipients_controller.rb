class AdditionalRecipientsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!, only: [:new, :create, :edit, :update]
  before_action :set_additional_recipient, only: [:edit, :update, :destroy]

  # GET /additional_recipients
  # GET /additional_recipients.json
  def index
    @additional_recipients = AdditionalRecipient.all
  end

  # GET /additional_recipients/new
  def new
    @additional_recipient = AdditionalRecipient.new
  end

  # GET /additional_recipients/1/edit
  def edit
  end

  # POST /additional_recipients
  # POST /additional_recipients.json
  def create
    @additional_recipient = AdditionalRecipient.new(additional_recipient_params)

    respond_to do |format|
      if @additional_recipient.save
        format.html { redirect_to additional_recipients_path, notice: 'Additional recipient was successfully created.' }
        format.json { render :index, status: :created, location: @additional_recipient }
      else
        format.html { render :new }
        format.json { render json: @additional_recipient.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /additional_recipients/1
  # PATCH/PUT /additional_recipients/1.json
  def update
    respond_to do |format|
      if @additional_recipient.update(additional_recipient_params)
        format.html { redirect_to additional_recipients_path, notice: 'Additional recipient was successfully updated.' }
        format.json { render :index, status: :ok, location: @additional_recipient }
      else
        format.html { render :edit }
        format.json { render json: @additional_recipient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /additional_recipients/1
  # DELETE /additional_recipients/1.json
  def destroy
    @additional_recipient.destroy
    respond_to do |format|
      format.html { redirect_to additional_recipients_url, notice: 'Additional recipient was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_additional_recipient
      @additional_recipient = AdditionalRecipient.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def additional_recipient_params
      params.require(:additional_recipient).permit(:email)
    end
end
