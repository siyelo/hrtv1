class ReportsController < ApplicationController
  layout 'reporter' #TODO: separate reporter/admin actions
  #authorize_resource :class => Reports
  before_filter :require_user

  TYPE_MAP = {'budget' => CodingBudget, 'spend' => CodingSpend}

  def activities_by_district
    authorize! :read, :activities_by_district
    rep = Reports::ActivitiesByDistrict.new
    send_csv(rep.csv, "activities_by_district.csv")
  end

  def activities_by_district_sub_activities
    authorize! :read, :activities_by_district_sub_activities
    rep = Reports::ActivitiesByDistrictSubActivities.new
    send_csv(rep.csv, "activities_by_district_sub_activities.csv")
  end

  def activities_by_budget_coding
    authorize! :read, :activities_by_budget_coding
    rep = Reports::ActivitiesByBudgetCoding.new
    send_csv(rep.csv, "activities_by_budget_coding.csv")
  end

  def activities_by_budget_cost_cat
    authorize! :read, :activities_by_budget_cost_cat
    rep = Reports::ActivitiesByBudgetCostCat.new
    send_csv(rep.csv, "activities_by_budget_cost_cat.csv")
  end

  def activities_by_budget_districts
    authorize! :read, :activities_by_budget_cost_cat
    rep = Reports::ActivitiesByBudgetDistricts.new
    send_csv(rep.csv, "activities_by_budget_districts.csv")
  end

  def activities_by_expenditure_coding
    authorize! :read, :activities_by_expenditure_coding
    rep = Reports::ActivitiesByExpenditureCoding.new
    send_csv(rep.csv, "activities_by_expenditure_coding.csv")
  end

  def activities_by_expenditure_cost_cat
    authorize! :read, :activities_by_expenditure_cost_cat
    rep = Reports::ActivitiesByExpenditureCostCat.new
    send_csv(rep.csv, "activities_by_expenditure_cost_cat.csv")
  end

  def activities_by_expenditure_districts
    authorize! :read, :activities_by_expenditure_cost_cat
    rep = Reports::ActivitiesByExpenditureDistricts.new
    send_csv(rep.csv, "activities_by_expenditure_districts.csv")
  end

  def users_by_organization
    authorize! :read, :users_by_organization
    rep = Reports::UsersByOrganization.new
    send_csv(rep.csv, "users_by_organization.csv")
  end

  def users_in_my_organization
    authorize! :read, :users_in_my_organization
    rep = Reports::UsersByOrganization.new(current_user)
    send_csv(rep.csv, "users_by_organization.csv")
  end

  # TODO ALL NEED TO BE AUTHORIZED!!!
  def activity_report
    rep = Reports::ActivityReport.new
    send_csv(rep.csv,"activity_report.csv")
  end

  def activities_by_district_row_report
    rep = Reports::DistrictCodingsBudgetReport.new
    send_csv(rep.csv,"activities_by_district_row_report.csv")
  end

  def activities_by_district_new
    rep = Reports::ActivitiesByDistrictNew.new
    send_csv(rep.csv,"activities_by_districts_new.csv")
  end

  # TODO remove, not being used
  def activities_by_budget_coding_new
    rep = Reports::ActivitiesByBudgetCodingNew.new
    send_csv(rep.csv,"activities_by_budget_coding_new.csv")
  end

  def activities_by_budget_stratprog
    rep = Reports::ActivitiesByHssp2.new
    send_csv(rep.csv,"activities_by_budget_stratprog.csv")
  end

  def activities_by_nsp
    set_activities
    rep = Reports::ActivitiesByNsp.new(@activities, budget_report_type, current_user.admin? )
    send_csv(rep.csv,"activities_by_nsp.csv")
  end

  def districts_by_nsp
    set_activities
    rep = Reports::DistrictsByNsp.new(@activities, budget_report_type)
    send_csv(rep.csv,"districts_by_nsp.csv")
  end

  def map_districts_by_nsp
    set_activities
    rep = Reports::MapDistrictsByNsp.new(@activities, budget_report_type)
    send_csv(rep.csv,"map_districts_by_nsp.csv")
  end
  def activities_by_full_coding
    set_activities
    rep = Reports::ActivitiesByFullCoding.new(@activities, budget_report_type, current_user.admin? )
    send_csv(rep.csv, "activities_by_full_coding.csv")
  end

  def all_codes
    rep = Reports::AllCodes.new
    send_csv(rep.csv, "all_codes.csv")
  end

  def districts_by_full_coding
    set_activities
    rep = Reports::DistrictsByFullCoding.new(@activities, budget_report_type)
    send_csv(rep.csv,"districts_by_full_coding.csv")
  end

  def map_districts_by_full_coding
    set_activities
    rep = Reports::MapDistrictsByFullCoding.new(@activities, budget_report_type)
    send_csv(rep.csv,"map_districts_by_full_coding.csv")
  end

  def map_districts_by_partner
    authorize! :read, :activities_by_expenditure_cost_cat
    rep = Reports::MapDistrictsByPartner.new(@activities, params[:type])
    send_csv(rep.csv,"map_districts_by_partner.csv")
  end

  def map_facilities_by_partner
    authorize! :read, :activities_by_expenditure_cost_cat
    rep = Reports::MapFacilitiesByPartner.new(@activities, params[:type])
    send_csv(rep.csv,"map_facilities_by_partner.csv")
  end

  def joint_annual_workplan_report
    rep = Reports::JointAnnualWorkplanReport.new(current_user)
    send_csv(rep.csv, "joint_annual_workplan_report.csv")
  end

  protected

    def set_activities
      if current_user.admin?
        #dr = DataResponse.find(params[:id])
        # THIS BREAKS ADMINS GETTING REPORTS FOR ONLY ONE DR
        # I DONT THINK SITE LINKS TO ANY REPORTS LIKE THAT AT THE MOMENT
        @activities = Activity.only_simple.canonical
      else
        dr = current_user.data_responses.find(params[:id])
        @activities = dr.activities
      end
    end

    def send_csv(text, filename)
      send_data text,
                :type => 'text/csv; charset=iso-8859-1; header=present',
                :disposition => "attachment; filename=#{filename}"
    end

    def budget_report_type
      TYPE_MAP[params[:type]] || CodingBudget
    end
end
