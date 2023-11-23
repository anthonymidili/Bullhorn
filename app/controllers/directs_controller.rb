class DirectsController < ApplicationController
  before_action :set_direct, only: %i[ show edit update destroy ]

  # GET /directs or /directs.json
  def index
    @directs = current_user.directs
  end

  # GET /directs/1 or /directs/1.json
  def show
  end

  # GET /directs/new
  def new
    @direct = current_user.directs.build
  end

  # GET /directs/1/edit
  def edit
  end

  # POST /directs or /directs.json
  def create
    user = User.search_by(params[:search]).first
    @direct = current_user.find_or_create_direct_message(user)

    respond_to do |format|
      if @direct.update(direct_params)
        format.html { redirect_to direct_url(@direct), notice: "Direct was successfully created." }
        format.json { render :show, status: :created, location: @direct }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @direct.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /directs/1 or /directs/1.json
  def update
    user = User.search_by(params[:search]).first
    @direct.users << user if user && !@direct.users.include?(user)

    respond_to do |format|
      if @direct.update(direct_params)
        format.html { redirect_to direct_url(@direct), notice: "Direct was successfully updated." }
        format.json { render :show, status: :ok, location: @direct }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @direct.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /directs/1 or /directs/1.json
  def destroy
    @direct.destroy

    respond_to do |format|
      format.html { redirect_to directs_url, notice: "Direct was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def personal
    user = User.find_by(id: params[:user_id])
    if user
      direct = current_user.find_or_create_direct_message(user)
      redirect_to direct
    else
      redirect_to root
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_direct
      @direct = current_user.directs.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def direct_params
      params.require(:direct).permit(:name)
    end
end
