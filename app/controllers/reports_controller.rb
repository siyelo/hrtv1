class ReportsController < ApplicationController

  #authorize_resource :class => Reports

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

    send_data rep.csv,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=users_by_organization.csv"
  end

  def activity_report
    rep = Reports::ActivityReport.new

    send_data rep.csv,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=activity_report.csv"
  end

  def activities_by_district_row_report
    rep = Reports::DistrictCodingsBudgetReport.new

    send_data rep.csv,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=activities_by_district_row_report.csv"
  end

  def activities_by_district_new
    rep = Reports::ActivitiesByDistrictNew.new

    send_data rep.csv,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=activities_by_districts_new.csv"
  end

  def activities_by_budget_coding_new
    rep = Reports::ActivitiesByBudgetCodingNew.new

    send_data rep.csv,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=activities_by_budget_coding_new.csv"
  end

  def activities_by_budget_stratprog
    rep = Reports::ActivitiesByHssp2.new

    send_data rep.csv,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=activities_by_budget_stratprog.csv"
  end

  def activities_by_nsp
    #TODO - security
    activities = DataResponse.find(params[:data_response_id]).activities
    rep = Reports::ActivitiesByNsp.new(activities)
    send_data rep.csv,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=activities_by_nsp.csv"
  end
end
