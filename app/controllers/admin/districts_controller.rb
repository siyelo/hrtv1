class Admin::DistrictsController < Admin::BaseController

  def index
    @locations = Location.all_with_counters
    @spent_codings = CodingSpendDistrict.find(:all,
                       :select => "code_id, SUM(cached_amount) AS total",
                       :conditions => ["code_id IN (?)", @locations.map(&:id)], :group => 'code_id')
    @budget_codings = CodingBudgetDistrict.find(:all,
                       :select => "code_id, SUM(cached_amount) AS total",
                       :conditions => ["code_id IN (?)", @locations.map(&:id)], :group => 'code_id')
  end

  def show
    @location = Location.find(params[:id])
    @mtef_spent_pie_values        = DistrictPies::mtef_spent(@location)
    @mtef_budget_pie_values       = DistrictPies::mtef_budget(@location)
  end

end
