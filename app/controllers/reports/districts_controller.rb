class Reports::DistrictsController < Reports::BaseController
  MTEF_CODE_LEVEL = 1 # all level 1 MTEF codes

  def index
    @locations = Location.all_with_counters
    @spent_codings = CodingSpendDistrict.find(:all,
                       :select => "code_id, SUM(new_cached_amount_in_usd) AS total",
                       :conditions => ["code_id IN (?)", @locations.map(&:id)],
                       :group => 'code_id')
    @budget_codings = CodingBudgetDistrict.find(:all,
                       :select => "code_id, SUM(new_cached_amount_in_usd) AS total",
                       :conditions => ["code_id IN (?)", @locations.map(&:id)],
                       :group => 'code_id')
  end

  def show
    @location = Location.find(params[:id])
    @treemap = params[:chart_type] == "treemap" || params[:chart_type].blank?
    code_type = get_code_type_and_initialize(params[:code_type])

    if @treemap
      @code_spent_values   = DistrictTreemaps::treemap(@location, code_type, @location.activities, true)
      @code_budget_values  = DistrictTreemaps::treemap(@location, code_type, @location.activities, false)
    else
      @code_spent_values   = DistrictPies::pie(@location, code_type, true, MTEF_CODE_LEVEL)
      @code_budget_values  = DistrictPies::pie(@location, code_type, false, MTEF_CODE_LEVEL)
    end


    @top_activities    = Activity.top_by_spent({
                         :limit => 5, :code_ids => [@location.id], :type => 'district'})
    @top_organizations = Organization.top_by_spent({
                         :limit => 5, :code_ids => [@location.id], :type => 'district'})
  end
end
