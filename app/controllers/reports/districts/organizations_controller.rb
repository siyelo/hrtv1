class Reports::Districts::OrganizationsController < Reports::BaseController
  MTEF_CODE_LEVEL = 1 # all level 1 MTEF codes
  before_filter :load_location
  before_filter :load_request

  def index
    @organizations     = Reports::OrganizationReport.top_by_spent_and_budget({
                         :data_request_id => @current_request.id,
                         :per_page => 25,
                         :page => params[:page],
                         :sort => params[:sort],
                         :code_ids => [@location.id],
                         :type => 'district'})
    @spent_pie_values  = Charts::DistrictPies::organizations(@location, "CodingSpendDistrict", @current_request.id)
    @budget_pie_values = Charts::DistrictPies::organizations(@location, "CodingBudgetDistrict", @current_request.id)
  end

  def show
    @organization = Organization.reporting.find(params[:id])
    @treemap      = params[:chart_type] == "treemap"
    @pie          = params[:chart_type] == "pie" || params[:chart_type].blank?
    code_type     = get_code_type_and_initialize(params[:code_type])
    @chart_name   = get_chart_name(params[:code_type])
    activities    = @organization.dr_activities

    if @pie
      if @hssp2_strat_prog || @hssp2_strat_obj
        @code_spent_values   = Charts::DistrictPies::hssp2_strat_activities_pie(@location, code_type, true, @current_request.id, activities)
        @code_budget_values  = Charts::DistrictPies::hssp2_strat_activities_pie(@location, code_type, false, @current_request.id, activities)
      else
        @code_spent_values  = Charts::DistrictPies::organization_pie(@location, activities, code_type, true, @current_request.id)
        @code_budget_values = Charts::DistrictPies::organization_pie(@location, activities, code_type, false, @current_request.id)
      end
    else
    @code_spent_values   = Charts::DistrictTreemaps::treemap(@current_request.id, @location, code_type, activities, true)
      @code_budget_values  = Charts::DistrictTreemaps::treemap(@current_request.id, @location, code_type, activities, false)
    end
  end

  private

    def load_location
      @location = Location.find(params[:district_id])
    end
end
