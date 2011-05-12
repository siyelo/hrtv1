class Reports::Countries::OrganizationsController < Reports::BaseController

  def index
    @organizations     = Reports::OrganizationReport.top_by_spent_and_budget({
                         :per_page => 25, :page => params[:page], :sort => params[:sort],
                         :code_ids => Mtef.roots.map(&:id), :type => 'country'})
    @spent_pie_values  = Charts::CountryPies::organizations_pie("CodingSpend")
    @budget_pie_values = Charts::CountryPies::organizations_pie("CodingBudget")
  end

  def show
    @organization = Organization.find(params[:id])
    @treemap = params[:chart_type] == "treemap"
    @pie = params[:chart_type] == "pie" || params[:chart_type].blank?
    code_type = get_code_type_and_initialize(params[:code_type])
    code_type     = get_code_type_and_initialize(params[:code_type])
    activities    = @organization.dr_activities

    if @pie
      if @hssp2_strat_prog || @hssp2_strat_obj
        @code_spent_values  = Charts::CountryPies::hssp2_strat_activities_pie(code_type, true, activities)
        @code_budget_values = Charts::CountryPies::hssp2_strat_activities_pie(code_type, false, activities)
      else
        @code_spent_values  = Charts::CountryPies::codes_for_activities_pie(code_type, activities, true)
        @code_budget_values = Charts::CountryPies::codes_for_activities_pie(code_type, activities, false)
      end
    else
      @code_spent_values  = Charts::CountryTreemaps::treemap(code_type, activities, true)
      @code_budget_values = Charts::CountryTreemaps::treemap(code_type, activities, false)
    end
  end
end
