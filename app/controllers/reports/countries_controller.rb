class Reports::CountriesController < Reports::BaseController

  def show
    @pie      = params[:chart_type] == "pie" || params[:chart_type].blank?
    code_type = get_code_type_and_initialize(params[:code_type])

    if @pie
      @code_spent_values   = CountryPies::codes_for_country_pie(code_type, true)
      @code_budget_values  = CountryPies::codes_for_country_pie(code_type, false)
    else
      @code_spent_values   = CountryTreemaps::treemap(code_type, :all, true)
      @code_budget_values  = CountryTreemaps::treemap(code_type, :all, false)
    end

    code_ids               = Mtef.roots.map(&:id)
    @top_activities        = Reports::ActivityReport.top_by_spent({
                              :limit => 10, :code_ids => code_ids, :type => 'country'})
    @top_organizations     = Reports::OrganizationReport.top_by_spent({
                              :limit => 10, :code_ids => code_ids, :type => 'country'})

    @budget_ufs_values = CountryPies::ultimate_funding_sources('budget')
    @budget_fa_values  = CountryPies::financing_agents('budget')
    @budget_i_values   = CountryPies::implementers('budget')
    @spend_ufs_values  = CountryPies::ultimate_funding_sources('spend')
    @spend_fa_values   = CountryPies::financing_agents('spend')
    @spend_i_values    = CountryPies::implementers('spend')
  end
end
