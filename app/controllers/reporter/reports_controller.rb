class Reporter::ReportsController < Reporter::BaseController
  include ReportsControllerHelpers

  def index
    @data_responses = current_user.data_responses
  end

  def show
    report      = get_report
    report_name = params[:type].present? ?
      "#{params[:id]}_#{params[:type]}.csv" : "#{params[:id]}.csv"

    send_csv(report.csv, report_name)
  end

  private

    def get_report
      report_type = get_report_type(params[:type])
      case params[:id]
      when 'users_in_my_organization'
        Reports::UsersByOrganization.new(current_user)
      when 'all_codes'
        Reports::AllCodes.new
      when 'activities_by_nsp'
        Reports::ActivitiesByNsp.new(activities, report_type, current_user.admin?)
      when 'activities_by_all_codes'
        Reports::ActivitiesByAllCodes.new(activities, report_type, current_user.admin? )
      when 'districts_by_nsp'
        Reports::DistrictsByNsp.new(activities, report_type)
      when 'districts_by_all_codes'
        Reports::DistrictsByAllCodes.new(activities, report_type)
      when 'map_districts_by_nsp'
        Reports::MapDistrictsByNsp.new(activities, report_type)
      when 'map_districts_by_all_codes'
        Reports::MapDistrictsByAllCodes.new(activities, report_type)
      else
        raise "Invalid report request '#{params[:id]}'"
      end
    end

    def activities
      dr = current_user.data_responses.find(params[:dr_id])
      @activities = dr.activities
    end
end
