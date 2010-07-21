class StaticPageController < ApplicationController
  before_filter :require_user

  
  def index
  end

  def show
    render :action => params[:page]
  end
end

