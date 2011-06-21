class Reports::Countries::ActivitiesController < Reports::BaseController

  def index
    data_request_id    = current_user.current_data_response.data_request.id
    @activities        = Reports::ActivityReport.top_by_spent_and_budget({
                         :per_page => 25,
                         :page => params[:page],
                         :sort => params[:sort],
                         :data_request_id => data_request_id,
                         :code_ids => Mtef.roots.map(&:id), :type => 'country'})
    @spent_pie_values  = Charts::CountryPies::activities_pie("CodingSpend", data_request_id)
    @budget_pie_values = Charts::CountryPies::activities_pie("CodingBudget", data_request_id)
  end

  def show
    @activity       = Activity.find(params[:id])
    @pie            = params[:chart_type] == "pie" || params[:chart_type].blank?
    code_type       = get_code_type_and_initialize(params[:code_type])
    @chart_name     = get_chart_name(params[:code_type])
    data_request_id = current_user.current_data_response.data_request.id

    if @pie
      if @hssp2_strat_prog || @hssp2_strat_obj
        @code_spent_values  = Charts::CountryPies::hssp2_strat_activities_pie(code_type, data_request_id, true, [@activity])
        @code_budget_values = Charts::CountryPies::hssp2_strat_activities_pie(code_type, data_request_id, false, [@activity])
      else
        @code_spent_values    = Charts::CountryPies::codes_for_activities_pie(code_type, data_request_id, [@activity], true)
        @code_budget_values   = Charts::CountryPies::codes_for_activities_pie(code_type, data_request_id, [@activity], false)
      end
    else
      @code_spent_values    = Charts::CountryTreemaps::treemap(code_type, [@activity], data_request_id, true)
      @code_budget_values   = Charts::CountryTreemaps::treemap(code_type, [@activity], data_request_id, false)
    end

    @charts_loaded          = @code_spent_values && @code_budget_values
    @spent_assignments_sum  = @activity.coding_budget_sum_in_usd
    @budget_assignments_sum = @activity.coding_budget_sum_in_usd

    unless @charts_loaded
      flash.now[:warning] = "Sorry, the Organization hasn't yet properly classified this Activity yet, so some of the charts may be missing!"
    end
  end
end
