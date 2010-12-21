class Reports::Districts::ActivitiesController < Reports::BaseController
  before_filter :load_location

  def index
    @activities        = Activity.top_by_spent_and_budget({:per_page => 25, :page => params[:page], :code_id => @location.id})
    @spent_pie_values  = DistrictPies::activities_spent(@location)
    @budget_pie_values = DistrictPies::activities_budget(@location)
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
        @code_spent_values   = DistrictTreemaps::district_mtef_spent(@location, [@activity])
        @code_budget_values  = DistrictTreemaps::district_mtef_budget(@location, [@activity])
      else
        @code_spent_values  = DistrictPies::activity_mtef_spent(@location, @activity)
        @code_budget_values = DistrictPies::activity_mtef_budget(@location, @activity)
      end
    else
      @nsp = true
      if @treemap
        @code_spent_values   = DistrictTreemaps::nsp_spent(@location, [@activity])
        @code_budget_values  = DistrictTreemaps::nsp_budget(@location, [@activity])
      else
        @code_spent_values   = DistrictPies::activity_nsp_spent(@location, @activity)
        @code_budget_values  = DistrictPies::activity_nsp_budget(@location, @activity)
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
