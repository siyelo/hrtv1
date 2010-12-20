class Admin::Districts::OrganizationsController < Admin::BaseController
  MTEF_CODE_LEVEL = 1 # all level 1 MTEF codes
  before_filter :load_location

  def index
    @spent_pie_values  = DistrictPies::organizations(@location, "CodingSpendDistrict")
    @budget_pie_values = DistrictPies::organizations(@location, "CodingBudgetDistrict")
    @organizations     = Organization.top_by_spent_and_budget({:per_page => 25, :page => params[:page], :code_id => @location.id})
  end

  def show
    @organization               = Organization.find(params[:id])

    @treemap = params[:chart_type] == "treemap" || params[:chart_type].blank?

    activities = @organization.dr_activities
    case params[:code_type]
    when "mtef"
      @mtef = true
      if @treemap
        @code_spent_values   = DistrictTreemaps::district_mtef_spent(@location, activities)
        @code_budget_values  = DistrictTreemaps::district_mtef_budget(@location, activities)
      else
        @code_spent_values  = DistrictPies::organization_mtef_spent(@location, activities)
        @code_budget_values = DistrictPies::organization_mtef_budget(@location, activities)
      end
    else
      @nsp = true
      if @treemap
        @code_spent_values   = DistrictTreemaps::nsp_spent(@location, activities)
        @code_budget_values  = DistrictTreemaps::nsp_budget(@location, activities)
      else
        @code_spent_values   = DistrictPies::organization_nsp_spent(@location, activities)
        @code_budget_values  = DistrictPies::organization_nsp_budget(@location, activities)
      end
    end
  end

  private

    def load_location
      @location = Location.find(params[:district_id])
    end
end
