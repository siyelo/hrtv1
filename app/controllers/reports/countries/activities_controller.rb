class Reports::Countries::ActivitiesController < Reports::BaseController

  def index
    @activities        = Activity.top_by_spent_and_budget({
                                                            :per_page => 25,
                                                            :page => params[:page],
                                                            :code_ids => Mtef.roots.map(&:id),
                                                            :type => 'country'
                                                          })
    @spent_pie_values  = CountryPies::activities("CodingSpend")
    @budget_pie_values = CountryPies::activities("CodingBudget")
  end

  def show
    @activity                   = Activity.find(params[:id])

    @treemap = params[:chart_type] == "treemap" || params[:chart_type].blank?

    case params[:code_type]
    when "mtef"
      @mtef = true
      if @treemap
        @code_spent_values   = CountryTreemaps::treemap('mtef', true, [@activity])
        @code_budget_values  = CountryTreemaps::treemap('mtef', false, [@activity])
      else
        @code_spent_values  = CountryPies::activity_pie('mtef', true, @activity)
        @code_budget_values = CountryPies::activity_pie('mtef', false, @activity)
      end
    when 'cost_category'
      @cost_category = true
      if @treemap
        @code_spent_values   = CountryTreemaps::treemap('cost_category', true, [@activity])
        @code_budget_values  = CountryTreemaps::treemap('cost_category', false, [@activity])
      else
        @code_spent_values  = CountryPies::activity_pie('cost_category', true, @activity)
        @code_budget_values = CountryPies::activity_pie('cost_category', false, @activity)
      end
    else
      @nsp = true
      if @treemap
        @code_spent_values   = CountryTreemaps::treemap('nsp', true, [@activity])
        @code_budget_values  = CountryTreemaps::treemap('nsp', false, [@activity])
      else
        @code_spent_values   = CountryPies::activity_pie('nsp', true, @activity)
        @code_budget_values  = CountryPies::activity_pie('nsp', false, @activity)
      end
    end
    @charts_loaded  = @spent_pie_values && @budget_pie_values &&
                      @code_spent_values && @code_budget_values

    unless @charts_loaded
      flash.now[:warning] = "Sorry, the Organization hasn't yet properly classified this Activity yet, so some of the charts may be missing!"
    end
  end
end
