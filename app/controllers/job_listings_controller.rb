class JobListingsController < ApplicationController
  before_action :authenticate_user!
  before_action :company_set?, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_job_listing, only: [:edit, :update, :destroy]
  before_action :set_as_read!, only: [:show]

  # GET /job_listings
  # GET /job_listings.json
  def index
    @job_listings =
      if params[:search]
        JobListing.by_currently_listed.search_by(params[:search]).
        includes(company: [:address, logo_attachment: :blob])
      else
        JobListing.by_currently_listed.
        includes(company: [:address, logo_attachment: :blob])
      end
  end

  # GET /job_listings/1
  # GET /job_listings/1.json
  def show
    @job_listing = JobListing.find_by(id: params[:id])
    if @job_listing.nil? || !@job_listing.currently_listed? && !correct_user?(@job_listing.user)
      redirect_to job_listings_path
    end
  end

  # GET /job_listings/new
  def new
    @job_listing = current_company.job_listings.new
  end

  # GET /job_listings/1/edit
  def edit
  end

  # POST /job_listings
  # POST /job_listings.json
  def create
    @job_listing = current_company.job_listings.new(job_listing_params)

    respond_to do |format|
      if @job_listing.save
        format.html { redirect_to @job_listing, notice: 'Job listing was successfully created.' }
        format.json { render :show, status: :created, location: @job_listing }
      else
        format.html { render :new }
        format.json { render json: @job_listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /job_listings/1
  # PATCH/PUT /job_listings/1.json
  def update
    respond_to do |format|
      if @job_listing.update(job_listing_params)
        format.html { redirect_to @job_listing, notice: 'Job listing was successfully updated.' }
        format.json { render :show, status: :ok, location: @job_listing }
      else
        format.html { render :edit }
        format.json { render json: @job_listing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /job_listings/1
  # DELETE /job_listings/1.json
  def destroy
    @job_listing.destroy
    respond_to do |format|
      format.html { redirect_to job_listings_url, notice: 'Job listing was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    @job_listings = JobListing.search_by(params[:term])
    render json: @job_listings.map(&:title).uniq
  end

private

  def company_set?
    redirect_to companies_path unless current_company
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_job_listing
    @job_listing = current_company.job_listings.find_by(id: params[:id])
    redirect_to job_listings_path unless @job_listing
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def job_listing_params
    params.require(:job_listing).permit(:title, :classification, :status, :comp_min,
      :comp_max, :comp_per, :description, :apply_email, :is_listed, :dur_interval, :dur_cal_type)
  end
end
