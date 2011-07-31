class Reports::Districts::ActivitiesController < Reports::BaseController
  before_filter :load_location
  before_filter :require_district_reports_permission

  def index
    @activities        = Reports::ActivityReport.top_by_spent_and_budget({
                         :data_request_id => current_request.id,
                         :per_page => 25,
                         :page => params[:page],
                         :sort => params[:sort],
                         :code_ids => [@location.id],
                         :type => 'district'})
    @spent_pie_values  = Charts::DistrictPies::activities(@location, "CodingSpendDistrict", current_request.id)
    @budget_pie_values = Charts::DistrictPies::activities(@location, "CodingBudgetDistrict", current_request.id)
  end

  def show
    @activity          = Activity.find(params[:id])
    load_comment_resources(@activity)
    @spent_pie_values  = Charts::DistrictPies::activity_spent_ratio(@location, @activity, current_request.id)
    @budget_pie_values = Charts::DistrictPies::activity_budget_ratio(@location, @activity, current_request.id)
    @pie               = params[:chart_type] == "pie" || params[:chart_type].blank?
    code_type          = get_code_type_and_initialize(params[:code_type])
    @chart_name        = get_chart_name(params[:code_type])


    if @pie
      if @hssp2_strat_prog || @hssp2_strat_obj
        @code_spent_values   = Charts::DistrictPies::hssp2_strat_activities_pie(@location, code_type, true, current_request.id, [@activity])
        @code_budget_values  = Charts::DistrictPies::hssp2_strat_activities_pie(@location, code_type, false, current_request.id, [@activity])

      else
        @code_spent_values  = Charts::DistrictPies::activity_pie(@location, @activity, code_type, true, current_request.id)
        @code_budget_values = Charts::DistrictPies::activity_pie(@location, @activity, code_type, false, current_request.id)
      end
    else
      @code_spent_values  = Charts::DistrictTreemaps::treemap(current_request.id, @location, code_type, [@activity], true)
      @code_budget_values = Charts::DistrictTreemaps::treemap(current_request.id, @location, code_type, [@activity], false)
    end

    @charts_loaded  = @spent_pie_values && @budget_pie_values &&
                      @code_spent_values && @code_budget_values

    @spent_assignments_sum    = @activity.coding_spend_district_sum_in_usd(@location)
    @budget_assignments_sum   = @activity.coding_budget_district_sum_in_usd(@location)

    unless @charts_loaded
      flash.now[:warning] = "Sorry, the Organization hasn't yet properly classified this Activity yet, so some of the charts may be missing!"
    end
  end

  private

    def load_location
      @location = Location.find(params[:district_id])
    end

    def require_district_reports_permission
      check_district_reports_access_for_location(params[:district_id])
    end
end
