class Admin::Districts::OrganizationsController < Admin::BaseController
  before_filter :load_location

  def index
    @spent_pie_values  = DistrictPies::organizations(@location, "CodingSpendDistrict")
    @budget_pie_values = DistrictPies::organizations(@location, "CodingBudgetDistrict")
    @organizations     = Organization.top_by_spent_and_budget({:per_page => 25, :page => params[:page], :code_id => @location.id})
  end

  private

    def load_location
      @location = Location.find(params[:district_id])
    end
end
