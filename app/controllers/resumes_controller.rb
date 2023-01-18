class ResumesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_resume, only: [:edit, :update, :destroy]
  before_action :deny_access!, only: [:edit, :update, :destroy],
  unless:  -> { correct_user?(@resume.try(:user)) }

  # GET /resumes
  # GET /resumes.json
  def index
    @resumes = Resume.by_currently_listed
  end

  # GET /resumes/new
  def new
    @resume = current_user.build_resume
  end

  # GET /resumes/1/edit
  def edit
  end

  # POST /resumes
  # POST /resumes.json
  def create
    @resume = current_user.build_resume(resume_params)

    respond_to do |format|
      if @resume.save
        format.html { redirect_to resume_user_path(current_user), notice: 'Resume was successfully created.' }
        format.json { render :show, status: :created, location: @resume }
      else
        format.html { render :new }
        format.json { render json: @resume.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /resumes/1
  # PATCH/PUT /resumes/1.json
  def update
    respond_to do |format|
      if @resume.update(resume_params)
        format.html { redirect_to resume_user_path(current_user), notice: 'Resume was successfully updated.' }
        format.json { render :show, status: :ok, location: @resume }
      else
        format.html { render :edit }
        format.json { render json: @resume.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /resumes/1
  # DELETE /resumes/1.json
  def destroy
    @resume.destroy
    respond_to do |format|
      format.html { redirect_to resumes_url, notice: 'Resume was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_resume
    @resume = current_user.resume
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resume_params
    params.require(:resume).permit(:title, :classification, :status, :is_listed, :file)
  end
end
