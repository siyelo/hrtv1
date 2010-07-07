class StaticPageController < ApplicationController
  PAGES = %w[about contact ngo_dashboard govt_dashboard admin_dashboard] #allowable (non-index) pages rendered by show action
  
  def index
  end
  
  def show
    render :action => params[:page]
  end

end
