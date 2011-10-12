class ReportsController < BaseController
  include ReportsControllerHelpers
  include PrepareCharts

  before_filter :load_response

  def index
    load_dashboard_charts
  end

  def show
    send_csv(report.csv, report_name)
  end

  private

    def report
      case params[:id]
      when 'purposes'
        Reports::AllCodes.new(Mtef)
      when 'inputs'
        Reports::AllCodes.new(CostCategory)
      when 'locations'
        Reports::AllCodes.new(Location)
      else
        raise "Invalid report request '#{params[:id]}'" #TODO GN this should do security exception
      end
    end
end
