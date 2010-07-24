class StaticPageController < ApplicationController
  skip_before_filter :load_help

  before_filter :require_user, :except => [:index, :news, :about]

  def index
  end
  def news
  end
  def about
  end

  def show
    #TODO add authorization for the various dashboards
    render :action => params[:page]
  end
end

