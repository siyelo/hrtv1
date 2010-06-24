class StaticPageController < ApplicationController
  PAGES = %w[about, contact] #allowable (non-index) pages rendered by show action
  
  def index
  end
  
  def show
    render :action => params[:page]
  end

end
