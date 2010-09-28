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
    @unfulfilled_responses = DataResponse.unfulfilled
  end

  def submit
    root_activities         = current_user.current_data_response.activities.roots
    other_cost_activities = current_user.current_data_response.activities.with_type("OtherCost")
    @uncoded_activities     = root_activities.reject{ |a| a.classified }
    @uncoded_other_costs    = other_cost_activities.reject{ |a| a.classified }
    @warnings               = []
    @warnings               << :other_costs_missing if other_cost_activities.empty?
    @warnings               << :activities_missing  if root_activities.empty?
  end

  def show
    #TODO add authorization for the various dashboards
    render :action => params[:page]
  end
end

