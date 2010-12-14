class StaticPageController < ApplicationController
  layout 'promo_inner'
  skip_before_filter :load_help

  before_filter :require_user, :except => [:index, :news, :contact, :about]

  def index
    @user_session = UserSession.new
    render :layout => 'promo'
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

  protected
  # Don't require SSL for index, about, contact and news actions
  # redefined method from application_controller.rb
  def ssl_required?
    if ['index', 'about', 'contact', 'news'].include?(action_name)
      false
    else
      super
    end
  end

  # Allow SSL for index, about, contact and news actions
  # redefined method from SSL requirement plugin
  def ssl_allowed?
    if ['index', 'about', 'contact', 'news'].include?(action_name)
      true
    else
      super
    end
  end
end

