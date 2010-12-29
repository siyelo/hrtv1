class Reports::Districts::OrganizationsController < Reports::BaseController
  MTEF_CODE_LEVEL = 1 # all level 1 MTEF codes
  before_filter :load_location

  def index
    @organizations     = Organization.top_by_spent_and_budget({
                                                               :per_page => 25,
                                                               :page => params[:page],
                                                               :code_ids => [@location.id],
                                                               :type => 'district'
                                                             })
    @spent_pie_values  = DistrictPies::organizations(@location, "CodingSpendDistrict")
    @budget_pie_values = DistrictPies::organizations(@location, "CodingBudgetDistrict")
  end

  def show
    @organization               = Organization.find(params[:id])

    @treemap = params[:chart_type] == "treemap" || params[:chart_type].blank?

    activities = @organization.dr_activities
    case params[:code_type]
    when "mtef"
      @mtef = true
      if @treemap
        @code_spent_values   = DistrictTreemaps::treemap(@location, activities, 'mtef', true)
        @code_budget_values  = DistrictTreemaps::treemap(@location, activities, 'mtef', false)
      else
        @code_spent_values  = DistrictPies::organization_pie(@location, activities, 'mtef', true)
        @code_budget_values = DistrictPies::organization_pie(@location, activities, 'mtef', false)
      end
    when 'cost_category'
      @cost_category = true
      if @treemap
        @code_spent_values   = DistrictTreemaps::treemap(@location, activities, 'cost_category', true)
        @code_budget_values  = DistrictTreemaps::treemap(@location, activities, 'cost_category', false)
      else
        @code_spent_values  = DistrictPies::organization_pie(@location, activities, 'cost_category', true)
        @code_budget_values = DistrictPies::organization_pie(@location, activities, 'cost_category', false)
      end
    else
      @nsp = true
      if @treemap
        @code_spent_values   = DistrictTreemaps::treemap(@location, activities, 'nsp', true)
        @code_budget_values  = DistrictTreemaps::treemap(@location, activities, 'nsp', false)
      else
        @code_spent_values   = DistrictPies::organization_pie(@location, activities, 'nsp', true)
        @code_budget_values  = DistrictPies::organization_pie(@location, activities, 'nsp', false)
      end
    end
  end

  private

    def load_location
      @location = Location.find(params[:district_id])
    end
end
