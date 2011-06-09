class Reports::DistrictsController < Reports::BaseController
  MTEF_CODE_LEVEL = 1 # all level 1 MTEF codes

  def index
    @locations        = Location.all_with_counters(current_or_last_response.data_request_id)
    @spent_codings    = CodingSpendDistrict.with_request(current_or_last_response.data_request_id).sum(:cached_amount_in_usd,
                          :conditions => ["code_id IN (?)", @locations.map(&:id)],
                          :group => 'code_id')
    @budget_codings   = CodingBudgetDistrict.with_request(current_or_last_response.data_request_id).sum(:cached_amount_in_usd,
                          :conditions => ["code_id IN (?)", @locations.map(&:id)],
                          :group => 'code_id')
  end

  def show
    @location   = Location.find(params[:id])
    @pie        = params[:chart_type] == "pie" || params[:chart_type].blank?
    code_type   = get_code_type_and_initialize(params[:code_type])
    @chart_name = get_chart_name(params[:code_type])

    if @pie
      if @hssp2_strat_prog || @hssp2_strat_obj
        @code_spent_values   = Charts::DistrictPies::hssp2_strat_activities_pie(@location, code_type, true, current_or_last_response.data_request_id)
        @code_budget_values  = Charts::DistrictPies::hssp2_strat_activities_pie(@location, code_type, false, current_or_last_response.data_request_id)
      else
        @code_spent_values   = Charts::DistrictPies::pie(current_or_last_response.data_request_id, @location, code_type, true, MTEF_CODE_LEVEL)
        @code_budget_values  = Charts::DistrictPies::pie(current_or_last_response.data_request_id, @location, code_type, false, MTEF_CODE_LEVEL)
      end
    else
      @code_spent_values   = Charts::DistrictTreemaps::treemap(current_or_last_response.data_request_id, @location, code_type, @location.activities, true)
      @code_budget_values  = Charts::DistrictTreemaps::treemap(current_or_last_response.data_request_id, @location, code_type, @location.activities, false)
    end

    @top_activities    = Reports::ActivityReport.top_by_spent({
                         :limit => 10, :code_ids => [@location.id], :type => 'district', :data_request_id => current_or_last_response.data_request_id})
    @top_organizations = Reports::OrganizationReport.top_by_spent({
                         :limit => 10, :code_ids => [@location.id], :type => 'district', :data_request_id => current_or_last_response.data_request_id})


    @budget_ufs_values = Charts::DistrictPies::ultimate_funding_sources(@location, 'budget', current_or_last_response.data_request_id)
    @budget_fa_values  = Charts::DistrictPies::financing_agents(@location, 'budget', current_or_last_response.data_request_id)
    @budget_i_values   = Charts::DistrictPies::implementers(@location, 'budget', current_or_last_response.data_request_id)
    @spend_ufs_values  = Charts::DistrictPies::ultimate_funding_sources(@location, 'spend', current_or_last_response.data_request_id)
    @spend_fa_values   = Charts::DistrictPies::financing_agents(@location, 'spend', current_or_last_response.data_request_id)
    @spend_i_values    = Charts::DistrictPies::implementers(@location, 'spend', current_or_last_response.data_request_id)
  end
end
