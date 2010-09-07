class ReportsController < ApplicationController

  authorize_resource :class => Reports

  def activities_by_district
    rep = Reports::ActivitiesByDistrict.new

    send_data rep.csv,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=activities_by_district.csv"
  end

  def activities_by_district_sub_activities
    rep = Reports::ActivitiesByDistrictSubActivities.new

    send_data rep.csv,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=activities_by_district_sub_activities.csv"
  end

  def activities_by_budget_coding
    rep = Reports::ActivitiesByBudgetCoding.new

    send_data rep.csv,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=activities_by_budget_coding.csv"
  end

  def activities_by_budget_cost_cat
    rep = Reports::ActivitiesByBudgetCostCat.new

    send_data rep.csv,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=activities_by_budget_cost_cat.csv"
  end

  def activities_by_expenditure_coding
    rep = Reports::ActivitiesByExpenditureCoding.new

    send_data rep.csv,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=activities_by_expenditure_coding.csv"
  end

  def activities_by_expenditure_cost_cat
    rep = Reports::ActivitiesByExpenditureCostCat.new

    send_data rep.csv,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=activities_by_expenditure_cost_cat.csv"
  end

end

