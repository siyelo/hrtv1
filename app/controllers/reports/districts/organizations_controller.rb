class Reports::Districts::OrganizationsController < Reports::BaseController
  MTEF_CODE_LEVEL = 1 # all level 1 MTEF codes
  before_filter :load_location

  def index
    data_request_id    = current_user.current_data_response.data_request.id
    @organizations     = Reports::OrganizationReport.top_by_spent_and_budget({
                         :data_request_id => data_request_id,
                         :per_page => 25,
                         :page => params[:page],
                         :sort => params[:sort],
                         :code_ids => [@location.id],
                         :type => 'district'})
    @spent_pie_values  = Charts::DistrictPies::organizations(@location, "CodingSpendDistrict", data_request_id)
    @budget_pie_values = Charts::DistrictPies::organizations(@location, "CodingBudgetDistrict", data_request_id)
  end

  def show
    data_request_id    = current_user.current_data_response.data_request.id
    @organization = Organization.reporting.find(params[:id])
    @treemap      = params[:chart_type] == "treemap"
    @pie          = params[:chart_type] == "pie" || params[:chart_type].blank?
    code_type     = get_code_type_and_initialize(params[:code_type])
    @chart_name   = get_chart_name(params[:code_type])
    activities    = @organization.dr_activities

    if @pie
      if @hssp2_strat_prog || @hssp2_strat_obj
        @code_spent_values   = Charts::DistrictPies::hssp2_strat_activities_pie(@location, code_type, true, data_request_id, activities)
        @code_budget_values  = Charts::DistrictPies::hssp2_strat_activities_pie(@location, code_type, false, data_request_id,activities)
      else
        @code_spent_values  = Charts::DistrictPies::organization_pie(@location, activities, code_type, true, data_request_id)
        @code_budget_values = Charts::DistrictPies::organization_pie(@location, activities, code_type, false, data_request_id)
      end
    else
    @code_spent_values   = Charts::DistrictTreemaps::treemap(data_request_id, @location, code_type, activities, true)
      @code_budget_values  = Charts::DistrictTreemaps::treemap(data_request_id, @location, code_type, activities, false)
    end
  end

  private

    def load_location
      @location = Location.find(params[:district_id])
    end
end
