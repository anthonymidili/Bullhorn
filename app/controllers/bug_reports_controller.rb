class BugReportsController < ApplicationController
  before_action :authenticate_admin!, only: [:index, :show, :edit, :update, :destroy]
  before_action :set_bug_report, only: %i[ show edit update destroy ]

  # GET /bug_reports or /bug_reports.json
  def index
    @bug_reports = BugReport.by_created_at
    @status = params[:status] || "new"
  end

  # GET /bug_reports/1 or /bug_reports/1.json
  def show
  end

  # GET /bug_reports/new
  def new
    @bug_report = BugReport.new
  end

  # GET /bug_reports/1/edit
  def edit
  end

  # POST /bug_reports or /bug_reports.json
  def create
    @bug_report = BugReport.new(bug_report_params)
    @bug_report.user = current_user if current_user

    respond_to do |format|
      if @bug_report.save
        format.html { redirect_to root_path, notice: "Bug report was successfully created." }
        format.json { render :index, status: :created, location: "sites#index" }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @bug_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bug_reports/1 or /bug_reports/1.json
  def update
    respond_to do |format|
      if @bug_report.update(bug_report_params)
        format.html { redirect_to bug_report_url(@bug_report), notice: "Bug report was successfully updated." }
        format.json { render :show, status: :ok, location: @bug_report }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @bug_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bug_reports/1 or /bug_reports/1.json
  def destroy
    @bug_report.destroy

    respond_to do |format|
      format.html { redirect_to bug_reports_url, notice: "Bug report was successfully destroyed." }
      format.json { head :no_content }
    end
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_bug_report
    @bug_report = BugReport.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def bug_report_params
    params.require(:bug_report).permit(:subject, :body, :name, :email, :status)
  end
end
