class Admin::DistrictsController < Admin::BaseController

  def index
    @locations = Location.all
  end

  def show
    @location = Location.find(params[:id])
  end

end
