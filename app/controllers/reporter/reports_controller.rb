class Reporter::ReportsController < Reporter::BaseController
  include ReportsControllerHelpers

  def index
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
        Reports::ActivitiesByNsp.new(activities, :budget, current_user.admin?)
      when 'activities_by_all_codes_budget'
        Reports::ActivitiesByAllCodes.new(activities, :budget, current_user.admin? )
      when 'districts_by_nsp_budget'
        Reports::DistrictsByNsp.new(activities, :budget)
      when 'districts_by_all_codes_budget'
        Reports::DistrictsByAllCodes.new(activities, :budget)
      when 'map_districts_by_nsp_budget'
        Reports::MapDistrictsByNsp.new(activities, :budget)
      when 'map_districts_by_all_codes_budget'
        Reports::MapDistrictsByAllCodes.new(activities, :budget)
      else
        raise "Invalid report request '#{params[:id]}'" #TODO GN this should do security exception
      end
    end

    def activities
      dr = current_user.data_responses.find(params[:dr_id])
      @activities = dr.activities
    end
end
