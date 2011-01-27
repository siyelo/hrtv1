class Reports::CountriesController < Reports::BaseController

  def show
    @treemap = params[:chart_type] == "treemap" || params[:chart_type].blank?
    code_type = get_code_type_and_initialize(params[:code_type])

    if @treemap
      @code_spent_values   = Charts::CountryTreemaps::treemap(code_type, :all, true)
      @code_budget_values  = Charts::CountryTreemaps::treemap(code_type, :all, false)
    else
      @code_spent_values   = Charts::CountryPies::codes_for_country_pie(code_type, true)
      @code_budget_values  = Charts::CountryPies::codes_for_country_pie(code_type, false)
    end

    code_ids = Mtef.roots.map(&:id)
    @top_activities        = Activity.top_by_spent({
                              :limit => 5, :code_ids => code_ids, :type => 'country'})
    @top_organizations     = Organization.top_by_spent({
                              :limit => 5, :code_ids => code_ids, :type => 'country'})
  end
end
