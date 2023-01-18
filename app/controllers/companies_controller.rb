class CompaniesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company, only: [:show, :edit, :update, :destroy, :remove_logo]

  # GET /companies
  # GET /companies.json
  def index
    @companies = current_user.companies.includes([:industry, :job_listings])
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
  end

  # GET /companies/new
  def new
    @company = current_user.companies.new
    @company.build_address
  end

  # GET /companies/1/edit
  def edit
    @company.address || @company.build_address
  end

  # POST /companies
  # POST /companies.json
  def create
    @company = current_user.companies.new(company_params)
    @company.address || @company.build_address

    respond_to do |format|
      if @company.save
        session[:current_company_id] = @company.id
        format.html { redirect_to new_job_listing_path, notice: 'Company was successfully created.' }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    @company.address || @company.build_address

    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to @company, notice: 'Company was successfully updated.' }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url, notice: 'Company was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    @industries = Industry.search_by(params[:term])
    render json: @industries.map(&:name)
  end

  def remove_logo
    @company.logo.purge
    redirect_to @company, notice: 'Logo has been removed.'
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = current_company
    redirect_to companies_path unless current_company
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def company_params
    params.require(:company).permit(:name, :comp_industry, :logo,
      address_attributes:[:id, :street_1, :street_2, :city, :state, :zip,
      :location, :_destroy])
  end
end
