class Admin::ReportsController < Admin::BaseController
  include ReportsControllerHelpers

  def index
    flash[:notice] = "If any of the reports time out or take too long, please email Steve Musau <Stephen_Musau@abtassoc.com> to get them."
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
      when 'districts_by_nsp'
        Reports::DistrictsByNsp.new(activities, report_type)
      when 'districts_by_all_codes'
        Reports::DistrictsByAllCodes.new(activities, report_type)
      when 'users_by_organization'
        Reports::UsersByOrganization.new
      when 'map_districts_by_partner'
        Reports::MapDistrictsByPartner.new(params[:type].to_s.to_sym)
      when 'map_districts_by_nsp'
        Reports::MapDistrictsByNsp.new(activities, report_type)
      when 'map_districts_by_all_codes'
        @activities = Activity.only_simple.canonical
        Reports::MapDistrictsByAllCodes.new(@activities, report_type)
      when 'map_facilities_by_partner'
        Reports::MapFacilitiesByPartner.new(params[:type].to_s.to_sym)
      when 'activity_report'
        Reports::ActivitiesSummary.new
      when 'activities_by_district'
        Reports::ActivitiesByDistrict.new
      when 'activities_one_row_per_district'
        Reports::ActivitiesOneRowPerDistrict.new
      when 'activities_by_budget_coding'
        Reports::ActivitiesByCoding.new(:budget)
      when 'activities_by_budget_cost_categorization'
        Reports::ActivitiesByCostCategorization.new(:budget)
      when 'activities_by_budget_districts'
        Reports::ActivitiesByDistricts.new(:budget)
      when 'activities_by_expenditure_coding'
        Reports::ActivitiesByCoding.new(:spent)
      when 'activities_by_expenditure_cost_categorization'
        Reports::ActivitiesByCostCategorization.new(:spent)
      when 'activities_by_expenditure_districts'
        Reports::ActivitiesByDistricts.new(:spent)
      when 'jawp_report'
        Reports::JawpReport.new(current_user, params[:type])
      when 'activities_by_nsp'
        Reports::ActivitiesByNsp.new(activities, report_type, current_user.admin?)
      when 'activities_by_nha'
        Reports::ActivitiesByNha.new(activities, report_type)
      when 'activities_by_all_codes'
        Reports::ActivitiesByAllCodes.new(activities, report_type, current_user.admin? )
      else
        raise "Invalid report request '#{params[:id]}'"
      end
    end

    def activities
      Activity.only_simple.canonical
    end
end
