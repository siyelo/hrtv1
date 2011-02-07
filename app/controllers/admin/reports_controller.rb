class Admin::ReportsController < Admin::BaseController
  include ReportsControllerHelpers

  def index
    flash.now[:notice] = "If any of the reports time out or take too long, please email Steve Musau <Stephen_Musau@abtassoc.com> to get them."
  end

  def show
    if params[:force] == "true"
      report = Report.create(:key => params[:id])
      time = report_time(Time.now.utc)
    else
      report = Report.find_last_by_key(params[:id])
      if report
        time = report_time(report.updated_at)
      else
        report = Report.create(:key => params[:id]) # if the report is not in database, generate it!
        time = report_time(Time.now.utc)
      end
    end

    redirect_to report.csv.url
  end

  private

    def report_time(time)
      time.strftime("%Y%m%d-%H%M")
    end
end
