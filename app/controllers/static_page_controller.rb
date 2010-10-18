class StaticPageController < ApplicationController
  skip_before_filter :load_help

  before_filter :require_user, :except => [:index, :news, :contact, :about]

  def index
    @user_session = UserSession.new
  end

  def news
  end

  def about
  end

  def contact
    redirect_to :controller => :help_requests, :action => :new
  end

  def submit
    redirect_to review_data_response_url(current_user.current_data_response)
  end

  def show
    #TODO add authorization for the various dashboards
    render :action => params[:page]
  end
end

