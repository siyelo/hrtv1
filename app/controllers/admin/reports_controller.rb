class Admin::ReportsController < Admin::BaseController
  include ReportsControllerHelpers

  def index
  end

  def show
    report = Report.find_last_by_key(params[:id])

    if params[:force] == "true" || report.nil?
      report = Report.create(:key => params[:id])
    end

    redirect_to report.csv.url
  end

end
