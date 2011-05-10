class Reports::DistrictsController < Reports::BaseController
  MTEF_CODE_LEVEL = 1 # all level 1 MTEF codes

  def index
    @locations        = Location.all_with_counters
    @total_population = District.sum(:population)
    @spent_codings    = CodingSpendDistrict.sum(:cached_amount_in_usd,
                          :conditions => ["code_id IN (?)", @locations.map(&:id)],
                          :group => 'code_id')
    @budget_codings   = CodingBudgetDistrict.sum(:cached_amount_in_usd,
                          :conditions => ["code_id IN (?)", @locations.map(&:id)],
                          :group => 'code_id')
  end

  def show
    @location = Location.find(params[:id])
    @pie      = params[:chart_type] == "pie" || params[:chart_type].blank?
    code_type = get_code_type_and_initialize(params[:code_type])

    if @pie
      @code_spent_values   = DistrictPies::pie(@location, code_type, true, MTEF_CODE_LEVEL)
      @code_budget_values  = DistrictPies::pie(@location, code_type, false, MTEF_CODE_LEVEL)
    else
      @code_spent_values   = DistrictTreemaps::treemap(@location, code_type, @location.activities, true)
      @code_budget_values  = DistrictTreemaps::treemap(@location, code_type, @location.activities, false)
    end

    @top_activities    = Reports::ActivityReport.top_by_spent({
                         :limit => 10, :code_ids => [@location.id], :type => 'district'})
    @top_organizations = Reports::OrganizationReport.top_by_spent({
                         :limit => 10, :code_ids => [@location.id], :type => 'district'})


    @budget_ufs_values = DistrictPies::ultimate_funding_sources(@location, 'budget')
    @budget_fa_values  = DistrictPies::financing_agents(@location, 'budget')
    @budget_i_values   = DistrictPies::implementers(@location, 'budget')
    @spend_ufs_values  = DistrictPies::ultimate_funding_sources(@location, 'spend')
    @spend_fa_values   = DistrictPies::financing_agents(@location, 'spend')
    @spend_i_values    = DistrictPies::implementers(@location, 'spend')
  end
end
