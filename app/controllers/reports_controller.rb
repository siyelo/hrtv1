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
      when 'users_in_my_organization'
        Reports::UsersByOrganization.new(current_user)
      when 'purposes'
        Reports::AllCodes.new(Mtef)
      when 'inputs'
        Reports::AllCodes.new(CostCategory)
      when 'locations'
        Reports::AllCodes.new(Location)
      when 'activities_by_nsp_budget'
        Reports::ActivitiesByNsp.new(activities, :budget)
      when 'activities_by_all_codes_budget'
        Reports::ActivitiesByAllCodes.new(activities, :budget)
      when 'districts_by_nsp_budget'
        Reports::DistrictsByNsp.new(@response.activities, :budget)
      when 'districts_by_all_codes_budget'
        Reports::DistrictsByAllCodes.new(@response.activities, :budget)
      when 'map_districts_by_nsp_budget'
        Reports::MapDistrictsByNsp.new(@response.activities, :budget)
      when 'map_districts_by_all_codes_budget'
        Reports::MapDistrictsByAllCodes.new(@response.activities, :budget)
      else
        raise "Invalid report request '#{params[:id]}'" #TODO GN this should do security exception
      end
    end
end
