# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < AuthlogicController
  helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details
  protect_from_forgery :only => [:create, :update, :destroy] # Active Scaffold fix
  filter_parameter_logging :password, :password_confirmation

  include ApplicationHelper
  include SslRequirement

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "You are not authorized to do that"
    redirect_to login_url
  end

  protected

    # Require SSL for all actions in all controllers
    # redefined method from SSL requirement plugin
    # This method is redefined in static pages controller for actions: :index, :about, :contact, :news
    def ssl_required?
      if Rails.env == "production" || Rails.env == "staging"# || Rails.env == "development"
        true
      else
        false
      end
    end

end
