class ReportsController < ApplicationController

  #authorize_resource :class => Reports
  before_filter :require_user

  TYPE_MAP = {'budget' => 'CodingBudget', 'spend' => 'CodingSpend'}

  def activities_by_district
    authorize! :read, :activities_by_district
    rep = Reports::ActivitiesByDistrict.new

    send_data rep.csv,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=activities_by_district.csv"
  end

  def activities_by_district_sub_activities
    authorize! :read, :activities_by_district_sub_activities
    rep = Reports::ActivitiesByDistrictSubActivities.new

    send_data rep.csv,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=activities_by_district_sub_activities.csv"
  end

  def activities_by_budget_coding
    authorize! :read, :activities_by_budget_coding
    rep = Reports::ActivitiesByBudgetCoding.new

    send_data rep.csv,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=activities_by_budget_coding.csv"
  end

  def activities_by_budget_cost_cat
    authorize! :read, :activities_by_budget_cost_cat
    rep = Reports::ActivitiesByBudgetCostCat.new

    send_data rep.csv,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=activities_by_budget_cost_cat.csv"
  end

  def activities_by_expenditure_coding
    authorize! :read, :activities_by_expenditure_coding
    rep = Reports::ActivitiesByExpenditureCoding.new

    send_data rep.csv,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=activities_by_expenditure_coding.csv"
  end

  def activities_by_expenditure_cost_cat
    authorize! :read, :activities_by_expenditure_cost_cat
    rep = Reports::ActivitiesByExpenditureCostCat.new

    send_data rep.csv,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=activities_by_expenditure_cost_cat.csv"
  end

  def users_by_organization
    authorize! :read, :users_by_organization
    rep = Reports::UsersByOrganization.new

    send_data rep.csv,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=users_by_organization.csv"
  end

  def users_in_my_organization
    authorize! :read, :users_in_my_organization
    rep = Reports::UsersByOrganization.new(current_user)
    send_csv rep.csv, "users_by_organization.csv"
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

  def activities_by_budget_coding_new
    rep = Reports::ActivitiesByBudgetCodingNew.new
    send_csv(rep.csv,"activities_by_budget_coding_new.csv")
  end

  def activities_by_budget_stratprog
    rep = Reports::ActivitiesByHssp2.new
    send_csv(rep.csv,"activities_by_budget_stratprog.csv")
  end

  def activities_by_nsp
    find_data_response
    rep = Reports::ActivitiesByNsp.new(@data_response.activities, TYPE_MAP[params[:type]] || 'BudgetCoding')
    send_csv(rep.csv,"activities_by_nsp.csv")
  end

  def districts_by_nsp
    find_data_response
    rep = Reports::DistrictsByNsp.new(@data_response.activities, TYPE_MAP[params[:type]] || 'BudgetCoding')
    send_csv(rep.csv,"districts_by_nsp.csv")
  end

  def map_districts_by_nsp
    find_data_response
    rep = Reports::MapDistrictsByNsp.new(@data_response.activities, TYPE_MAP[params[:type]] || 'BudgetCoding')
    send_csv(rep.csv,"map_districts_by_nsp.csv")
  end
  def activities_by_full_coding
    find_data_response
    rep = Reports::ActivitiesByFullCoding.new(@data_response.activities, TYPE_MAP[params[:type]] || 'BudgetCoding')
    send_csv(rep.csv, "activities_by_full_coding.csv")
  end

  def districts_by_full_coding
    find_data_response
    rep = Reports::DistrictsByFullCoding.new(@data_response.activities, TYPE_MAP[params[:type]] || 'BudgetCoding')
    send_csv(rep.csv,"districts_by_full_coding.csv")
  end

  def map_districts_by_full_coding
    find_data_response
    rep = Reports::MapDistrictsByFullCoding.new(@data_response.activities, TYPE_MAP[params[:type]] || 'BudgetCoding')
    send_csv(rep.csv,"map_districts_by_full_coding.csv")
  end

  protected

  def find_data_response
    if current_user.admin?
      @data_response = DataResponse.find(params[:id])
    else
      @data_response = current_user.data_responses.find(params[:id])
    end
  end

  def send_csv(text, filename)
    send_data text,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=#{filename}"
  end
end
