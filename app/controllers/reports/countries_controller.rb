class Reports::CountriesController < Reports::BaseController

  def show
    @location = Location.find(1574)
    @treemap = params[:chart_type] == "treemap" || params[:chart_type].blank?

    case params[:code_type]
    when "mtef"
      @mtef = true
      if @treemap
        @code_spent_values   = DistrictTreemaps::treemap(@location, @location.activities, 'mtef', true)
        @code_budget_values  = DistrictTreemaps::treemap(@location, @location.activities, 'mtef', false)
      else
        @code_spent_values   = DistrictPies::district_pie(@location, 'mtef', true, MTEF_CODE_LEVEL)
        @code_budget_values  = DistrictPies::district_pie(@location, 'mtef', false, MTEF_CODE_LEVEL)
      end
    when 'cost_category'
      @cost_category = true
      if @treemap
        @code_spent_values   = DistrictTreemaps::treemap(@location, @location.activities, 'cost_category', 'true')
        @code_budget_values  = DistrictTreemaps::treemap(@location, @location.activities, 'cost_category', false)
      else
        @code_spent_values   = DistrictPies::district_pie(@location, 'cost_category', true)
        @code_budget_values  = DistrictPies::district_pie(@location, 'cost_category', false)
      end
    else
      @nsp = true
      #TODO: - NSP level 1 or 2 etc
      if @treemap
        @code_spent_values   = DistrictTreemaps::treemap(@location, @location.activities, 'nsp', true)
        @code_budget_values  = DistrictTreemaps::treemap(@location, @location.activities, 'nsp', false)
      else
        @code_spent_values   = DistrictPies::district_pie(@location, 'nsp', true)
        @code_budget_values  = DistrictPies::district_pie(@location, 'nsp', false)
      end
    end

    @top_activities        = Activity.top_by_spent_for_country({:limit => 5})
    @top_organizations     = Organization.top_by_spent_for_country({:limit => 5})
  end
end
