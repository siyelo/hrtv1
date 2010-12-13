class Admin::Districts::ActivitiesController < Admin::BaseController
  before_filter  :load_location
  PRECISION = 6
  def index
    @activities = @location.activities.greatest_first
  end

  def show
    @activity = Activity.find(params[:id])
    @district_spent_ratio = @activity.coding_spend_district.with_location(@location).find(:first).amount / @activity.spend # % that this district has allocated
    @district_spent = @activity.spend * @district_spent_ratio
    @spent_ratio_pie_values = [["All Districts", @activity.spend.round(2)], ["#{@location.name}", @district_spent.round(2)]].to_json
    @district_budgeted_ratio = @activity.coding_budget_district.with_location(@location).find(:first).amount / @activity.spend # % that this district has allocated
    @district_budgeted = @activity.budget * @district_budgeted_ratio
    @budget_ratio_pie_values = [["All Districts", @activity.budget.round(2)], ["#{@location.name}", @district_budgeted.round(2)]].to_json

    @spent_pie_values = prepare_pie_values(CodingSpend.with_code_ids(Mtef.leaves).with_activity(@activity), @district_spent_ratio)
    @budget_pie_values = prepare_pie_values(CodingBudget.with_code_ids(Mtef.leaves).with_activity(@activity), @district_budgeted_ratio)
  end

  protected

    def load_location
      @location = Location.find(params[:district_id])
    end

    def prepare_pie_values(code_assignments, ratio)
      values = []
      code_assignments.each do |ca|
        values << [ca.code_name, (ca.calculated_amount * ratio).round(2)]
      end
      values.to_json
    end
end
