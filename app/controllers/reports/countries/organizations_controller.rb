class Reports::Countries::OrganizationsController < Reports::BaseController

  def index
    @organizations     = Organization.top_by_spent_and_budget({
                                                               :per_page => 25,
                                                               :page => params[:page],
                                                               :code_ids => Mtef.roots.map(&:id),
                                                               :type => 'country'
                                                             })
    @spent_pie_values  = CountryPies::organizations("CodingSpend")
    @budget_pie_values = CountryPies::organizations("CodingBudget")
  end

  def show
    @organization               = Organization.find(params[:id])

    @treemap = params[:chart_type] == "treemap" || params[:chart_type].blank?

    activities = @organization.dr_activities
    case params[:code_type]
    when "mtef"
      @mtef = true
      if @treemap
        @code_spent_values   = CountryTreemaps::treemap('mtef', true, activities)
        @code_budget_values  = CountryTreemaps::treemap('mtef', false, activities)
      else
        @code_spent_values  = CountryPies::organization_pie('mtef', true, activities)
        @code_budget_values = CountryPies::organization_pie('mtef', false, activities)
      end
    when 'cost_category'
      @cost_category = true
      if @treemap
        @code_spent_values   = CountryTreemaps::treemap('cost_category', true, activities)
        @code_budget_values  = CountryTreemaps::treemap('cost_category', false, activities)
      else
        @code_spent_values  = CountryPies::organization_pie('cost_category', true, activities)
        @code_budget_values = CountryPies::organization_pie('cost_category', false, activities)
      end
    else
      @nsp = true
      if @treemap
        @code_spent_values   = CountryTreemaps::treemap('nsp', true, activities)
        @code_budget_values  = CountryTreemaps::treemap('nsp', false, activities)
      else
        @code_spent_values   = CountryPies::organization_pie('nsp', true, activities)
        @code_budget_values  = CountryPies::organization_pie('nsp', false, activities)
      end
    end
  end
end
