class Reports::Districts::OrganizationsController < Reports::BaseController
  MTEF_CODE_LEVEL = 1 # all level 1 MTEF codes
  before_filter :load_location

  def index
    @organizations     = Reports::OrganizationReport.top_by_spent_and_budget({
                         :per_page => 25, :page => params[:page], :sort => params[:sort],
                         :code_ids => [@location.id], :type => 'district'})
    #@spent_pie_values  = Charts::DistrictPies::organizations(@location, "CodingSpendDistrict")
    #@budget_pie_values = Charts::DistrictPies::organizations(@location, "CodingBudgetDistrict")

    @budget_ufs_values = Charts::DistrictPies::ultimate_funding_sources(@location, 'budget')
    @budget_fa_values  = Charts::DistrictPies::financing_agents(@location, 'budget')
    @budget_i_values   = Charts::DistrictPies::implementers(@location, 'budget')
    @spend_ufs_values  = Charts::DistrictPies::ultimate_funding_sources(@location, 'spend')
    @spend_fa_values   = Charts::DistrictPies::financing_agents(@location, 'spend')
    @spend_i_values    = Charts::DistrictPies::implementers(@location, 'spend')
  end

  def show
    @organization      = Organization.find(params[:id])
    @treemap = params[:chart_type] == "treemap"
    @pie = params[:chart_type] == "pie" || params[:chart_type].blank?
    code_type = get_code_type_and_initialize(params[:code_type])
    activities         = @organization.dr_activities

    if @treemap
      @code_spent_values  = Charts::DistrictPies::organization_pie(@location, activities, code_type, true)
      @code_budget_values = Charts::DistrictPies::organization_pie(@location, activities, code_type, false)
    else
      @code_spent_values   = Charts::DistrictTreemaps::treemap(@location, code_type, activities, true)
      @code_budget_values  = Charts::DistrictTreemaps::treemap(@location, code_type, activities, false)
    end
  end

  private

    def load_location
      @location = Location.find(params[:district_id])
    end
end
