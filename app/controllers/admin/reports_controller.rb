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
      when 'districts_by_full_coding'
        Reports::DistrictsByFullCoding.new(activities, report_type)
      when 'users_by_organization'
        Reports::UsersByOrganization.new
      when 'map_districts_by_partner'
        # @activities is nil !? - that how it was in the old reports controller
        Reports::MapDistrictsByPartner.new(@activities, params[:type])
      when 'map_districts_by_nsp'
        Reports::MapDistrictsByNsp.new(activities, report_type)
      when 'map_districts_by_full_coding'
        @activities = Activity.only_simple.canonical
        Reports::MapDistrictsByFullCoding.new(@activities, report_type)
      when 'map_facilities_by_partner'
        # @activities is nil !? - that how it was in the old reports controller
        Reports::MapFacilitiesByPartner.new(@activities, params[:type])
      when 'activity_report'
        Reports::ActivityReport.new
      when 'activities_by_district_new'
        Reports::ActivitiesByDistrictNew.new
      when 'activities_by_district_row_report'
        Reports::DistrictCodingsBudgetReport.new
      when 'activities_by_budget_coding'
        Reports::ActivitiesByCoding.new(:budget)
      when 'activities_by_budget_cost_cat'
        Reports::ActivitiesByCostCategory.new(:budget)
      when 'activities_by_budget_districts'
        Reports::ActivitiesByDistricts.new(:budget)
      when 'activities_by_expenditure_coding'
        Reports::ActivitiesByCoding.new(:spent)
      when 'activities_by_expenditure_cost_cat'
        Reports::ActivitiesByCostCategory.new(:spent)
      when 'activities_by_expenditure_districts'
        Reports::ActivitiesByDistricts.new(:spent)
      when 'jawp_report'
        Reports::JawpReport.new(current_user, params[:type])
      when 'activities_by_nsp'
        Reports::ActivitiesByNsp.new(activities, report_type, current_user.admin?)
      when 'activities_by_nha'
        Reports::ActivitiesByNha.new(activities, report_type)
      when 'activities_by_full_coding'
        Reports::ActivitiesByFullCoding.new(activities, report_type, current_user.admin? )
      when 'activities_by_budget_coding_new' # TODO: remove, not being used
        Reports::ActivitiesByBudgetCodingNew.new
      when 'activities_by_budget_stratprog' # TODO: remove, not being used
        Reports::ActivitiesByHssp2.new
      when 'activities_by_district'
        Reports::ActivitiesByDistrict.new
      when 'activities_by_district_sub_activities'
        Reports::ActivitiesByDistrictSubActivities.new
      else
        raise "Invalid report request '#{params[:id]}'"
      end
    end

    def activities
      Activity.only_simple.canonical
    end
end
