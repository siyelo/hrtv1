class Admin::DistrictsController < ApplicationController
  before_filter :require_admin

  def index
    @locations = Location.all
  end

  def show
   @location = Location.find(params[:id])
  end

end
