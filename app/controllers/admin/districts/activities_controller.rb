class Admin::Districts::ActivitiesController < Admin::BaseController
  before_filter :load_location

  def index
    @spend_codings     = CodingSpendDistrict.with_code_id(@location.id).sort_cached_amt.paginate :page => params[:page], :per_page => 25, :include => {:activity => [{:data_response => :responding_organization}, :projects]}
    @spent_pie_values  = DistrictPies::activities_spent(@location)
    @budget_pie_values = DistrictPies::activities_budget(@location)
  end

  def show
    @activity               = Activity.find(params[:id])
    @spent_pie_values       = DistrictPies::load_spent_ratio_pie(@location, @activity)
    @budget_pie_values      = DistrictPies::load_budget_ratio_pie(@location, @activity)
    @mtef_spent_pie_values  = DistrictPies::load_mtef_spent_pie(@location, @activity)
    @mtef_budget_pie_values = DistrictPies::load_mtef_budget_pie(@location, @activity)
    @charts_loaded          = @spent_pie_values && @budget_pie_values &&
                               @mtef_spent_pie_values && @mtef_budget_pie_values

    unless @charts_loaded
      flash.now[:warning] = "Sorry, the Organization hasn't yet properly classified this Activity yet, so we can't generate any useful charts for you!"
    end
  end

  protected
    def load_location
      @location = Location.find(params[:district_id])
    end
end
