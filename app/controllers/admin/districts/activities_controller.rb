class Admin::Districts::ActivitiesController < Admin::BaseController
  before_filter  :load_location
  PRECISION = 6
  def index
    @activities = @location.activities.greatest_first
  end

  def show
    @activity = Activity.find(params[:id])
    @district_spend_coding = @activity.coding_spend_district.with_location(@location).find(:first)
    @spend_coded_ok = @district_spend_coding && @activity.spend && @activity.spend > 0 && @district_spend_coding.calculated_amount
    if @spend_coded_ok
      @district_spent_ratio   = @district_spend_coding.cached_amount / @activity.spend # % that this district has allocated
      @district_spent         = @activity.spend * @district_spent_ratio
      @spent_ratio_pie_values = prepare_ratio_pie_values(@activity.spend, @district_spent, "Spent activity / district ratio")
      @spent_pie_values       = prepare_pie_values(CodingSpend.with_code_ids(Mtef.leaves).with_activity(@activity), @district_spent_ratio, "Spent pie")
    end

    @district_budget_coding = @activity.coding_budget_district.with_location(@location).find(:first)
    @budget_coded_ok = @district_budget_coding && @activity.budget && @activity.budget > 0 && @district_budget_coding.calculated_amount
    if @budget_coded_ok
      @district_budgeted_ratio = @district_budget_coding.cached_amount / @activity.budget # % that this district has allocated
      @district_budgeted       = @activity.budget * @district_budgeted_ratio
      @budget_ratio_pie_values = prepare_ratio_pie_values(@activity.budget, @district_budgeted, "Budget activity / district ratio")
      @budget_pie_values = prepare_pie_values(CodingBudget.with_code_ids(Mtef.leaves).with_activity(@activity), @district_budgeted_ratio, "Budget pie")
    end

    unless @spend_coded_ok && @budget_coded_ok
      flash.now[:warning] = "Sorry, the Organization hasn't yet properly classified this Activity yet, so we can't generate any useful charts for you!"
    end
  end

  protected

    def load_location
      @location = Location.find(params[:district_id])
    end

    def prepare_pie_values(code_assignments, ratio, title)
      values = []
      code_assignments.each do |ca|
        values << [ca.code_name, (ca.calculated_amount * ratio).round(2)]
      end

      {
        :values => values,
        :names => {:column1 => 'Code name', :column2 => 'Amount', :title => title}
      }.to_json
    end

    def prepare_ratio_pie_values(activity_amount, district_amount, title)
      {
        :values => [
          ["All Districts", activity_amount.round(2)],
          ["#{@location.name}", district_amount.round(2)]
        ],
        :names => {:column1 => 'Code name', :column2 => 'Amount', :title => title}
      }.to_json
    end
end
