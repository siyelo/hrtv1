class Reports::DistrictsController < Reports::BaseController
  MTEF_CODE_LEVEL = 1 # all level 1 MTEF codes

  def index
    @locations = Location.all_with_counters
    @spent_codings = CodingSpendDistrict.find(:all,
                       :select => "code_id, SUM(new_cached_amount_in_usd) AS total",
                       :conditions => ["code_id IN (?)", @locations.map(&:id)], :group => 'code_id')
    @budget_codings = CodingBudgetDistrict.find(:all,
                       :select => "code_id, SUM(new_cached_amount_in_usd) AS total",
                       :conditions => ["code_id IN (?)", @locations.map(&:id)], :group => 'code_id')
  end

  def show
    @location = Location.find(params[:id])
    @treemap = params[:chart_type] == "treemap" || params[:chart_type].blank?

    case params[:code_type]
    when "mtef"
      @mtef = true
      if @treemap
        @code_spent_values   = DistrictTreemaps::treemap(@location, @location.activities, 'mtef', true)
        @code_budget_values  = DistrictTreemaps::treemap(@location, @location.activities, 'mtef', false)
      else
        @code_spent_values   = DistrictPies::pie(@location, 'mtef', true, MTEF_CODE_LEVEL)
        @code_budget_values  = DistrictPies::pie(@location, 'mtef', false, MTEF_CODE_LEVEL)
      end
    when 'cost_category'
      @cost_category = true
      if @treemap
        @code_spent_values   = DistrictTreemaps::treemap(@location, @location.activities, 'cost_category', 'true')
        @code_budget_values  = DistrictTreemaps::treemap(@location, @location.activities, 'cost_category', false)
      else
        @code_spent_values   = DistrictPies::pie(@location, 'cost_category', true)
        @code_budget_values  = DistrictPies::pie(@location, 'cost_category', false)
      end
    else
      @nsp = true
      #TODO: - NSP level 1 or 2 etc
      if @treemap
        @code_spent_values   = DistrictTreemaps::treemap(@location, @location.activities, 'nsp', true)
        @code_budget_values  = DistrictTreemaps::treemap(@location, @location.activities, 'nsp', false)
      else
        @code_spent_values   = DistrictPies::pie(@location, 'nsp', true)
        @code_budget_values  = DistrictPies::pie(@location, 'nsp', false)
      end
    end

    @top_activities    = Activity.top_by_spent({
                                                :limit => 5,
                                                :code_ids => [@location.id],
                                                :type => 'district'
                                              })
    @top_organizations = Organization.top_by_spent({
                                                    :limit => 5,
                                                    :code_ids => [@location.id],
                                                    :type => 'district'
                                                  })
  end
end
