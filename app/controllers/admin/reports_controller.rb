class Admin::ReportsController < Admin::BaseController
  include ReportsControllerHelpers

  before_filter :find_report, :only => [:edit, :update]

  def index
  end

  def show
    report = Report.find_last_by_key(params[:id])

    if params[:force] == "true" || report.nil?
      report = Report.create(:key => params[:id])
    end

    redirect_to report.csv.url
  end

  def new
    @report = Report.new()
  end

  # POST admin/reports
  def create
    @report  = Report.new(params[:report])
    respond_to do |format|
      if @report.save
        flash[:notice] = "Successfully created report"
        format.html { redirect_to admin_reports_path() }
      else
        format.html { render :action => :new }
      end
    end
  end

  def edit
  end

  def update
    @report.update_attributes params[:report]
    if @report.save
      flash[:notice] = "Successfully updated."
      redirect_to admin_reports_path()
    else
      render :action => :edit
    end
  end

  protected

    def find_report
      @report = Report.find params[:id]
    end

end
