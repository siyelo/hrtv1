class StaticPageController < ApplicationController
  skip_before_filter :load_help

  before_filter :require_user, :except => :index

  def index
  end

  def show
    render :action => params[:page]
  end
end

