class Admin::ReportsController < Admin::BaseController
  include ReportsControllerHelpers

  def index
    flash.now[:notice] = "If any of the reports time out or take too long, please email Steve Musau <Stephen_Musau@abtassoc.com> to get them."
  end

  def show
    if params[:force] == "true"
      report = generate_report
      time = report_time(Time.now.utc)
    else
      report = Report.find_last_by_key(params[:id])
      if report
        time = report_time(report.updated_at)
      else
        report = generate_report # if the report is not in database, generate it!
        time = report_time(Time.now.utc)
      end
    end

    send_csv(report.csv, "#{report_name}_#{time}")
  end

  private

    # NOTE: if you change something in this method,
    # be sure to update the rake task: reports.rake !!!
    def generate_report
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
        Reports::MapDistrictsByAllCodes.new(activities, :budget)
      when 'map_facilities_by_partner_budget'
        Reports::MapFacilitiesByPartner.new(:budget)
      when 'map_facilities_by_partner_spent'
        Reports::MapFacilitiesByPartner.new(:spent)
      when 'activities_summary'
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
        Reports::JawpReport.new(:budget)
      when 'jawp_report_spent'
        Reports::JawpReport.new(:spent)
      when 'activities_by_nsp_budget'
        Reports::ActivitiesByNsp.new(activities, :budget, true)
      when 'activities_by_nha'
        Reports::ActivitiesByNha.new(activities)
      when 'activities_by_all_codes_budget'
        Reports::ActivitiesByAllCodes.new(activities, :budget, true)
      else
        raise "Invalid report request '#{params[:id]}'"
      end
    end

    def activities
      Activity.only_simple.canonical
    end

    def report_time(time)
      time.strftime("%Y%m%d-%H%M")
    end
end
