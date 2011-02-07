class Admin::ReportsController < Admin::BaseController
  include ReportsControllerHelpers

  def index
    flash.now[:notice] = "If any of the reports time out or take too long, please email Steve Musau <Stephen_Musau@abtassoc.com> to get them."
  end

  def show
    report = Report.find_last_by_key(params[:id])

    if params[:force] == "true" || report.nil?
      report = Report.create(:key => params[:id])
    end

    redirect_to report.csv.url
  end

end
