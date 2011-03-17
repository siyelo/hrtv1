class StaticPageController < ApplicationController
  def index
    render :layout => 'promo'
  end

  def show
    render :action => params[:page]
  end

end

