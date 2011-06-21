class Reports::Countries::OrganizationsController < Reports::BaseController

  def index
    data_request_id    = current_user.current_data_response.data_request.id
    @organizations     = Reports::OrganizationReport.top_by_spent_and_budget({
                         :per_page => 25,
                         :page => params[:page],
                         :sort => params[:sort],
                         :data_request_id => data_request_id,
                         :code_ids => Mtef.roots.map(&:id), :type => 'country'})
    @spent_pie_values  = Charts::CountryPies::organizations_pie("CodingSpend", data_request_id)
    @budget_pie_values = Charts::CountryPies::organizations_pie("CodingBudget", data_request_id)
  end

  def show
    @organization   = Organization.find(params[:id])
    @treemap        = params[:chart_type] == "treemap"
    @pie            = params[:chart_type] == "pie" || params[:chart_type].blank?
    code_type       = get_code_type_and_initialize(params[:code_type])
    @chart_name     = get_chart_name(params[:code_type])
    activities      = @organization.dr_activities
    data_request_id = current_user.current_data_response.data_request.id

    if @pie
      if @hssp2_strat_prog || @hssp2_strat_obj
        @code_spent_values  = Charts::CountryPies::hssp2_strat_activities_pie(code_type, data_request_id, true, activities)
        @code_budget_values = Charts::CountryPies::hssp2_strat_activities_pie(code_type, data_request_id, false, activities)
      else
        @code_spent_values  = Charts::CountryPies::codes_for_activities_pie(code_type, data_request_id, activities, true)
        @code_budget_values = Charts::CountryPies::codes_for_activities_pie(code_type, data_request_id, activities, false)
      end
    else
      @code_spent_values  = Charts::CountryTreemaps::treemap(code_type, activities, data_request_id, true)
      @code_budget_values = Charts::CountryTreemaps::treemap(code_type, activities, data_request_id, false)
    end
  end
end
