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

  def reporter_dashboard
    @data_requests_unfulfilled = DataRequest.unfulfilled(current_user.organization)
    @data_requests_fulfilling = DataRequest.fulfilling(current_user.organization)
    @data_responses = current_user.data_responses
  end

  def submit
    redirect_to review_data_response_url(current_user.current_data_response)
  end

  def show
    #TODO add authorization for the various dashboards
    render :action => params[:page]
  end
end

