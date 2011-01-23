class Admin::ReportsController < Admin::BaseController
  include ReportsControllerHelpers

  def index
    flash[:notice] = "If any of the reports time out or take too long, please email Steve Musau <Stephen_Musau@abtassoc.com> to get them."
  end

  def show
    send_csv(report.csv, report_name)
  end

  private

    def report
      case params[:id]
      when 'districts_by_nsp_budget'
        Reports::DistrictsByNsp.new(activities, :budget)
      when 'districts_by_all_codes_budget'
        Reports::DistrictsByAllCodes.new(activities, :budget)
      when 'users_by_organization'
        Reports::UsersByOrganization.new
      when 'map_districts_by_partner_budget'
        Reports::MapDistrictsByPartner.new(:budget)
      when 'map_districts_by_partner_spent'
        Reports::MapDistrictsByPartner.new(:spent)
      when 'map_districts_by_nsp_budget'
        Reports::MapDistrictsByNsp.new(activities, :budget)
      when 'map_districts_by_all_codes_budget'
        @activities = Activity.only_simple.canonical
        Reports::MapDistrictsByAllCodes.new(@activities, :budget)
      when 'map_facilities_by_partner_budget'
        Reports::MapFacilitiesByPartner.new(:budget)
      when 'map_facilities_by_partner_spent'
        Reports::MapFacilitiesByPartner.new(:spent)
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
      when 'jawp_report_budget'
        Reports::JawpReport.new(current_user, :budget)
      when 'jawp_report_spent'
        Reports::JawpReport.new(current_user, :spent)
      when 'activities_by_nsp_budget'
        Reports::ActivitiesByNsp.new(activities, :budget, current_user.admin?)
      when 'activities_by_nha'
        Reports::ActivitiesByNha.new(activities)
      when 'activities_by_all_codes_budget'
        Reports::ActivitiesByAllCodes.new(activities, :budget, current_user.admin? )
      else
        raise "Invalid report request '#{params[:id]}'"
      end
    end

    def activities
      Activity.only_simple.canonical
    end
end
