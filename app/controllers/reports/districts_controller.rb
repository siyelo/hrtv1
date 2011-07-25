class Reports::DistrictsController < Reports::BaseController
  MTEF_CODE_LEVEL = 1 # all level 1 MTEF codes
  before_filter :restrict_district_manager_access, :only => [:index]
  before_filter :require_district_reports_permission, :only => [:show]

  def index
    @locations        = Location.all_with_counters(current_request.id)
    @spent_codings    = CodingSpendDistrict.with_request(current_request.id).sum(:cached_amount_in_usd,
                          :conditions => ["code_id IN (?)", @locations.map(&:id)],
                          :group => 'code_id')
    @budget_codings   = CodingBudgetDistrict.with_request(current_request.id).sum(:cached_amount_in_usd,
                          :conditions => ["code_id IN (?)", @locations.map(&:id)],
                          :group => 'code_id')
  end

  def show
    @location   = Location.find(params[:id])

    if params[:tab] == 'overview' || (params[:tab].blank? && params[:code_type].blank?)
      params[:tab] = 'overview' # set params[:tab] when params[:chart_type] is blank?
      @budget_i_values   = Charts::DistrictPies::implementers(@location, 'budget', current_request.id)
      @spend_i_values    = Charts::DistrictPies::implementers(@location, 'spend', current_request.id)
    elsif params[:tab] == 'funders_agents'
      @budget_ufs_values = Charts::DistrictPies::ultimate_funding_sources(@location, 'budget', current_request.id)
      @budget_fa_values  = Charts::DistrictPies::financing_agents(@location, 'budget', current_request.id)
      @spend_ufs_values  = Charts::DistrictPies::ultimate_funding_sources(@location, 'spend', current_request.id)
      @spend_fa_values   = Charts::DistrictPies::financing_agents(@location, 'spend', current_request.id)
    else
      @pie        = params[:chart_type] == "pie" || params[:chart_type].blank?
      code_type   = get_code_type_and_initialize(params[:code_type])
      @chart_name = get_chart_name(params[:code_type])

      if @pie
        if @hssp2_strat_prog || @hssp2_strat_obj
          @code_spent_values   = Charts::DistrictPies::hssp2_strat_activities_pie(@location, code_type, true, current_request.id)
          @code_budget_values  = Charts::DistrictPies::hssp2_strat_activities_pie(@location, code_type, false, current_request.id)
        else
          @code_spent_values   = Charts::DistrictPies::pie(current_request.id, @location, code_type, true, MTEF_CODE_LEVEL)
          @code_budget_values  = Charts::DistrictPies::pie(current_request.id, @location, code_type, false, MTEF_CODE_LEVEL)
        end
      else
        @code_spent_values   = Charts::DistrictTreemaps::treemap(current_request.id, @location, code_type, @location.activities, true)
        @code_budget_values  = Charts::DistrictTreemaps::treemap(current_request.id, @location, code_type, @location.activities, false)
      end
    end

    @top_activities    = Reports::ActivityReport.top_by_spent({
                         :limit => 10, :code_ids => [@location.id], :type => 'district', :data_request_id => current_request.id})
    @top_organizations = Reports::OrganizationReport.top_by_spent({
                         :limit => 10, :code_ids => [@location.id], :type => 'district', :data_request_id => current_request.id})
  end

  private
    def require_district_reports_permission
      check_district_reports_access_for_location(params[:id])
    end
end
