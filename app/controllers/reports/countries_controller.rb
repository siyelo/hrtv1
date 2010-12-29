class Reports::CountriesController < Reports::BaseController
  MTEF_CODE_LEVEL = 1 # all level 1 MTEF codes

  def show
    @treemap = params[:chart_type] == "treemap" || params[:chart_type].blank?

    case params[:code_type]
    when "mtef"
      @mtef = true
      if @treemap
        @code_spent_values   = CountryTreemaps::treemap('mtef', true)
        @code_budget_values  = CountryTreemaps::treemap('mtef', false)
      else
        @code_spent_values   = CountryPies::pie('mtef', true, MTEF_CODE_LEVEL)
        @code_budget_values  = CountryPies::pie('mtef', false, MTEF_CODE_LEVEL)
      end
    when 'cost_category'
      @cost_category = true
      if @treemap
        @code_spent_values   = CountryTreemaps::treemap('cost_category', 'true')
        @code_budget_values  = CountryTreemaps::treemap('cost_category', false)
      else
        @code_spent_values   = CountryPies::pie('cost_category', true)
        @code_budget_values  = CountryPies::pie('cost_category', false)
      end
    else
      @nsp = true
      #TODO: - NSP level 1 or 2 etc
      if @treemap
        @code_spent_values   = CountryTreemaps::treemap('nsp', true)
        @code_budget_values  = CountryTreemaps::treemap('nsp', false)
      else
        @code_spent_values   = CountryPies::pie('nsp', true)
        @code_budget_values  = CountryPies::pie('nsp', false)
      end
    end

    code_ids = Mtef.roots.map(&:id)
    @top_activities        = Activity.top_by_spent({
                                                    :limit => 5,
                                                    :code_ids => code_ids,
                                                    :type => 'country'
                                                  })
    @top_organizations     = Organization.top_by_spent({
                                                        :limit => 5,
                                                        :code_ids => code_ids,
                                                        :type => 'country'
                                                      })
  end
end
