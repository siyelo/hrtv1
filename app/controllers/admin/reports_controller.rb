class Admin::ReportsController < Admin::BaseController
  include ReportsControllerHelpers

  ### Filters
  before_filter :find_report, :only => [:show, :edit, :update]

  def index
    @reports = Report.all
    @report_map = @reports.map_to_hash{|r| {r.key => r}}
  end

  # returns the report csv, or the formatted csv
  def show
    url = @report.csv.url
    if params[:formatted] == "true"
      if @report.formatted_csv.exists?
        url = @report.formatted_csv.url
      else
        flash[:error] = "Formatted report does not exist."
        url = admin_reports_path()
      end
    end
    redirect_to url
  end

  def edit
  end

  def update
    if @report.update_attributes(params[:report])
      flash[:notice] = "Successfully updated."
      redirect_to admin_reports_path()
    else
      render :action => :edit
    end
  end

  # regenerate the report csv.
  # find it using the report key, if it exists.
  def generate
    @report = Report.find_or_initialize_by_key(params[:id])
    @report.generate_csv_zip(current_request)
    @report.save
    redirect_to @report.csv.url
  end

  protected

    def find_report
      @report = Report.find params[:id]
    end

end
