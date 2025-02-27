class EventsController < ApplicationController
  before_action :authenticate_user!
  include InfiniteScroll
  before_action :set_event, only: [ :edit, :update, :destroy, :remove_image ]
  before_action :deny_access!, only: [ :edit, :update, :destroy, :remove_image ],
    unless:  -> { correct_user?(@event.user) }
  before_action :set_timezone, only: [ :create, :update ]
  before_action :set_as_read!, only: [ :show ]

  # GET /events
  # GET /events.json
  def index
    @future_events = current_user.relevant_events.in_the_future.with_attached_image.
    includes(:comments, :address, user: [ avatar_attachment: :blob ])
    @past_events = @scrolled_objects # Returned objects in batches of 10.
  end

  # GET /events/1
  # GET /events/1.json
  def show
    # @event set in InfiniteScroll.rb.
    @comment = @event.comments.build
    @hidden = true
  end

  # GET /events/new
  def new
    @event = current_user.events.build
    @event.build_address
  end

  # GET /events/1/edit
  def edit
    @event.address || @event.build_address
  end

  # POST /events
  # POST /events.json
  def create
    @event = current_user.events.build(event_params)
    @event.address || @event.build_address

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: "Event was successfully created." }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    @event.address || @event.build_address
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: "Event was successfully updated." }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: "Event was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def remove_image
    @event.image.purge
    redirect_to @event, notice: "Image has been removed."
  end

  def calendar
    @events = current_user.relevant_events.future_and_past
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = current_user.relevant_events.with_attached_image.includes(comments: :created_by, users: [ avatar_attachment: :blob ]).find_by(id: params[:id])
    redirect_to events_path unless @event
  end

  def set_timezone
    Time.zone = event_params[:timezone]
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_params
    params.require(:event).permit(:name, :description, :start_date, :end_date,
      :timezone, :image, user_ids: [],
      address_attributes: [ :id, :street_1, :street_2, :city, :state, :zip,
      :location, :_destroy ])
  end
end
