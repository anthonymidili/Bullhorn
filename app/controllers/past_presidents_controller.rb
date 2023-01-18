class PastPresidentsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!, except: [:show]
  before_action :set_past_president, only: [:show, :edit, :update, :destroy]

  # GET /past_presidents/1
  # GET /past_presidents/1.json
  def show
  end

  # GET /past_presidents/new
  def new
    @past_president = PastPresident.new
  end

  # GET /past_presidents/1/edit
  def edit
  end

  # POST /past_presidents
  # POST /past_presidents.json
  def create
    @past_president = PastPresident.new(past_president_params)

    respond_to do |format|
      if @past_president.save
        format.html { redirect_to history_path(anchor: 'past_presidents'),
          notice: 'Past president was successfully created.' }
        format.json { render :show, status: :created, location: @past_president }
      else
        format.html { render :new }
        format.json { render json: @past_president.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /past_presidents/1
  # PATCH/PUT /past_presidents/1.json
  def update
    respond_to do |format|
      if @past_president.update(past_president_params)
        format.html { redirect_to history_path(anchor: 'past_presidents'),
          notice: 'Past president was successfully updated.' }
        format.json { render :show, status: :ok, location: @past_president }
      else
        format.html { render :edit }
        format.json { render json: @past_president.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /past_presidents/1
  # DELETE /past_presidents/1.json
  def destroy
    @past_president.destroy
    respond_to do |format|
      format.html {
        redirect_to history_url(anchor: 'past_presidents'),
        notice: 'Past president was successfully destroyed.'
      }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_past_president
      @past_president = PastPresident.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def past_president_params
      params.require(:past_president).permit(:first_name, :last_name,
        :term_order, :term_started_at, :term_ended_at, :bio, :avatar)
    end
end
