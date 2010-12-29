class Reports::Districts::ActivitiesController < Reports::BaseController
  before_filter :load_location

  def index
    @activities        = Activity.top_by_spent_and_budget({
                                                            :per_page => 25,
                                                            :page => params[:page],
                                                            :code_ids => [@location.id],
                                                            :type => 'district'
                                                          })
    @spent_pie_values  = DistrictPies::activities(@location, "CodingSpendDistrict")
    @budget_pie_values = DistrictPies::activities(@location, "CodingBudgetDistrict")
  end

  def show
    @activity                   = Activity.find(params[:id])
    @spent_pie_values           = DistrictPies::activity_spent_ratio(@location, @activity)
    @budget_pie_values          = DistrictPies::activity_budget_ratio(@location, @activity)

    @treemap = params[:chart_type] == "treemap" || params[:chart_type].blank?

    case params[:code_type]
    when "mtef"
      @mtef = true
      if @treemap
        @code_spent_values   = DistrictTreemaps::treemap(@location, [@activity], 'mtef', true)
        @code_budget_values  = DistrictTreemaps::treemap(@location, [@activity], 'mtef', false)
      else
        @code_spent_values  = DistrictPies::activity_pie(@location, @activity, 'mtef', true)
        @code_budget_values = DistrictPies::activity_pie(@location, @activity, 'mtef', false)
      end
    when 'cost_category'
      @cost_category = true
      if @treemap
        @code_spent_values   = DistrictTreemaps::treemap(@location, [@activity], 'cost_category', true)
        @code_budget_values  = DistrictTreemaps::treemap(@location, [@activity], 'cost_category', false)
      else
        @code_spent_values  = DistrictPies::activity_pie(@location, @activity, 'cost_category', true)
        @code_budget_values = DistrictPies::activity_pie(@location, @activity, 'cost_category', false)
      end
    else
      @nsp = true
      if @treemap
        @code_spent_values   = DistrictTreemaps::treemap(@location, [@activity], 'nsp', true)
        @code_budget_values  = DistrictTreemaps::treemap(@location, [@activity], 'nsp', false)
      else
        @code_spent_values   = DistrictPies::activity_pie(@location, @activity, 'nsp', true)
        @code_budget_values  = DistrictPies::activity_pie(@location, @activity, 'nsp', false)
      end
    end
    @charts_loaded  = @spent_pie_values && @budget_pie_values &&
                      @code_spent_values && @code_budget_values

    unless @charts_loaded
      flash.now[:warning] = "Sorry, the Organization hasn't yet properly classified this Activity yet, so some of the charts may be missing!"
    end
  end

  private

    def load_location
      @location = Location.find(params[:district_id])
    end
end
