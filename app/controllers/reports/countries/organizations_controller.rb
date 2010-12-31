class Reports::Countries::OrganizationsController < Reports::BaseController

  def index
    @organizations     = Organization.top_by_spent_and_budget({
                         :per_page => 25, :page => params[:page], :sort => params[:sort],
                         :code_ids => Mtef.roots.map(&:id), :type => 'country'})
    @spent_pie_values  = CountryPies::organizations_pie("CodingSpend")
    @budget_pie_values = CountryPies::organizations_pie("CodingBudget")
  end

  def show
    @organization = Organization.find(params[:id])
    @treemap      = params[:chart_type] == "treemap" || params[:chart_type].blank?
    code_type     = get_code_type_and_initialize(params[:code_type])
    activities    = @organization.dr_activities

    if @treemap
      @code_spent_values  = CountryTreemaps::treemap(code_type, activities, true)
      @code_budget_values = CountryTreemaps::treemap(code_type, activities, false)
    else
      @code_spent_values  = CountryPies::codes_for_activities_pie(code_type, activities, true)
      @code_budget_values = CountryPies::codes_for_activities_pie(code_type, activities, false)
    end
  end
end
