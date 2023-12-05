class DirectsController < ApplicationController
  include InfiniteScroll

  before_action :set_direct, only: %i[ edit update destroy ]

  # GET /directs or /directs.json
  def index
    @directs = current_user.directs
    @show_direct_link = true
  end

  # GET /directs/1 or /directs/1.json
  def show
    # @direct set in InfiniteScroll.rb.
    @messages = @scrolled_objects # Returned objects in batches of 10.
    @message = @direct.messages.build
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
    user = User.search_by(params[:search]).first unless params[:search].blank?
    @direct = 
      if user
        current_user.find_or_init_direct_message(user, direct_params)
      else
        current_user.directs.build(direct_params)
      end
    
    respond_to do |format|
      if @direct.save
        format.turbo_stream do
          flash[:notice] = "Direct message was successfully created."
          render turbo_stream: turbo_stream.action(:redirect, direct_url(@direct)) 
        end
        #   render turbo_stream: [
        #     turbo_stream.prepend("directs", partial: "directs/direct",
        #     locals: { direct: @direct }),
        #     turbo_stream.replace("new_direct", partial: "directs/new_direct_link")
        #   ]
        # end
        format.html { redirect_to direct_url(@direct), notice: "Direct message was successfully created." }
        format.json { render :show, status: :created, location: @direct }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("form_direct", partial: "directs/form",
            locals: { direct: @direct })
          ]
        end
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
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(@direct, partial: "directs/direct",
            locals: { direct: @direct })
          ]
        end
        format.html { redirect_to direct_url(@direct), notice: "Direct message was successfully updated." }
        format.json { render :show, status: :ok, location: @direct }
      else
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(helpers.dom_id(@direct, "form"), 
            partial: "directs/form", locals: { direct: @direct })
          ]
        end
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @direct.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /directs/1 or /directs/1.json
  def destroy
    @direct.destroy
    @from_show = params[:from_show]
    
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to directs_url, notice: "Direct message was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def personal
    user = User.find_by(id: params[:user_id])
    if user
      direct = current_user.find_or_init_direct_message(user, nil)
      direct.save if direct.new_record?
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
