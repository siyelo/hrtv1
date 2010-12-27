class Reports::DistrictsController < Reports::BaseController
  MTEF_CODE_LEVEL = 1 # all level 1 MTEF codes

  def index
    @locations = Location.all_with_counters
    @spent_codings = CodingSpendDistrict.find(:all,
                       :select => "code_id, SUM(cached_amount) AS total",
                       :conditions => ["code_id IN (?)", @locations.map(&:id)], :group => 'code_id')
    @budget_codings = CodingBudgetDistrict.find(:all,
                       :select => "code_id, SUM(cached_amount) AS total",
                       :conditions => ["code_id IN (?)", @locations.map(&:id)], :group => 'code_id')
  end

  def show
    @location = Location.find(params[:id])
    @treemap = params[:chart_type] == "treemap" || params[:chart_type].blank?

    case params[:code_type]
    when "mtef"
      @mtef = true
      if @treemap
        @code_spent_values   = DistrictTreemaps::district_mtef_spent(@location, @location.activities)
        @code_budget_values  = DistrictTreemaps::district_mtef_budget(@location, @location.activities)
      else
        @code_spent_values   = DistrictPies::activities_mtef_spent(@location, MTEF_CODE_LEVEL)
        @code_budget_values  = DistrictPies::activities_mtef_budget(@location, MTEF_CODE_LEVEL)
      end
    else
      @nsp = true
      #TODO: - NSP level 1 or 2 etc
      if @treemap
        @code_spent_values   = DistrictTreemaps::nsp_spent(@location, @location.activities)
        @code_budget_values  = DistrictTreemaps::nsp_budget(@location, @location.activities)
      else
        @code_spent_values   = DistrictPies::activities_nsp_spent(@location)
        @code_budget_values  = DistrictPies::activities_nsp_budget(@location)
      end
    end

    @top_activities        = Activity.top_by_spent({:limit => 5, :code_id => @location.id})
    @top_organizations     = Organization.top_by_spent({:limit => 5, :code_id => @location.id})
  end
end