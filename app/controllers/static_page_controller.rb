class StaticPageController < ApplicationController
  def index
  end

  def show
    render :action => params[:page]
  end
end
