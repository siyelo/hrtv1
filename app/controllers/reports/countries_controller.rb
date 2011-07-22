class Reports::CountriesController < Reports::BaseController

  def show
    @responses      = current_user.data_responses
    data_request_id = current_user.current_response.data_request.id

    if params[:tab] == 'overview' || (params[:tab].blank? && params[:code_type].blank?)
      params[:tab] = 'overview' # set params[:tab] when params[:chart_type] is blank?
      @budget_i_values   = Charts::CountryPies::implementers('budget', data_request_id)
      @spend_i_values    = Charts::CountryPies::implementers('spend', data_request_id)
    elsif params[:tab] == 'funders_agents'
      @budget_ufs_values = Charts::CountryPies::ultimate_funding_sources('budget', data_request_id)
      @budget_fa_values  = Charts::CountryPies::financing_agents('budget', data_request_id)
      @spend_ufs_values  = Charts::CountryPies::ultimate_funding_sources('spend', data_request_id)
      @spend_fa_values   = Charts::CountryPies::financing_agents('spend', data_request_id)
    else
      @pie            = params[:chart_type] == "pie" || params[:chart_type].blank?
      code_type       = get_code_type_and_initialize(params[:code_type])
      @chart_name     = get_chart_name(params[:code_type])

      if @pie
        if @hssp2_strat_prog || @hssp2_strat_obj
          @code_spent_values   = Charts::CountryPies::hssp2_strat_activities_pie(code_type, data_request_id, true)
          @code_budget_values  = Charts::CountryPies::hssp2_strat_activities_pie(code_type, data_request_id, false)
        else
          @code_spent_values   = Charts::CountryPies::codes_for_country_pie(code_type, data_request_id, true)
          @code_budget_values  = Charts::CountryPies::codes_for_country_pie(code_type, data_request_id, false)
        end
      else
        @code_spent_values   = Charts::CountryTreemaps::treemap(code_type, :all, data_request_id, true)
        @code_budget_values  = Charts::CountryTreemaps::treemap(code_type, :all, data_request_id, false)
      end
    end

    code_ids               = Mtef.roots.map(&:id)
    @top_activities        = Reports::ActivityReport.top_by_spent({
                               :limit => 10,
                               :code_ids => code_ids,
                               :type => 'country',
                               :data_request_id => data_request_id
                             })
    @top_organizations     = Reports::OrganizationReport.top_by_spent({
                               :limit => 10,
                               :code_ids => code_ids,
                               :type => 'country',
                               :data_request_id => data_request_id
                             })
  end
end
