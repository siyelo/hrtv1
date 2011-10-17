class Admin::ReportsController < Admin::BaseController
  include ReportsControllerHelpers

  ### Filters
  before_filter :find_report, :only => [:show, :edit, :update]

  def index
    @request    = current_user.current_request
    @response   = current_response
    @reports    = @request.reports.all
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

  def mark_implementer_splits
    file = params[:file]
    if file
      if is_zip?(file)
        csv = Report.unzip_csv(file.path)
      else
        csv = file.open.read
      end
      ImplementerSplit.mark_double_counting(csv)
      flash[:notice] = 'Your file is being processed, please reload this page in a couple of minutes to see the results'
    else
      flash[:error] = 'Please select a file to upload'
    end

    redirect_to admin_reports_url
  end

  # regenerate the report csv.
  # find it using the report key, if it exists.
  def generate
    @report = Report.find_or_initialize_by_key_and_data_request_id(params[:id], current_request.id)
    @report.generate_csv_zip
    @report.save
    redirect_to @report.csv.url
  end

  protected

    def is_zip?(file)
      File.extname(params[:file].original_filename).include? "zip"
    end

    def find_report
      @report = Report.find params[:id]
    end
end
