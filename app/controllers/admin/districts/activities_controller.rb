class Admin::Districts::ActivitiesController < Admin::BaseController
  before_filter :load_location

  def index
    @spend_codings     = CodingSpendDistrict.with_code_id(@location.id).sort_cached_amt.paginate :page => params[:page], :per_page => 25, :include => {:activity => [{:data_response => :responding_organization}, :projects]}
    @spent_pie_values  = DistrictPies::activities_spent(@location)
    @budget_pie_values = DistrictPies::activities_budget(@location)
  end

  def show
    @activity                   = Activity.find(params[:id])
    @spent_pie_values           = DistrictPies::activity_spent_ratio(@location, @activity)
    @budget_pie_values          = DistrictPies::activity_budget_ratio(@location, @activity)

    case params[:code_type]
    when "mtef"
      @mtef = true
      @code_spent_pie_values      = DistrictPies::activity_mtef_spent(@location, @activity)
      @code_budget_pie_values     = DistrictPies::activity_mtef_budget(@location, @activity)
      @code_spent_treemap_values  = DistrictTreemaps::district_mtef_spent(@location, [@activity])
      @code_budget_treemap_values = DistrictTreemaps::district_mtef_budget(@location, [@activity])
    else #default NSP
      @nsp = true
      @code_spent_pie_values      = DistrictPies::activity_nsp_spent(@location, @activity)
      @code_budget_pie_values     = DistrictPies::activity_nsp_budget(@location, @activity)
   end
    @charts_loaded  = @spent_pie_values && @budget_pie_values &&
                      @code_spent_pie_values && @code_budget_pie_values

    unless @charts_loaded
      flash.now[:warning] = "Sorry, the Organization hasn't yet properly classified this Activity yet, so we can't generate any useful charts for you!"
    end
  end

  protected

    def load_location
      @location = Location.find(params[:district_id])
    end
end
