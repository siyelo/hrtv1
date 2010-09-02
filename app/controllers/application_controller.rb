# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < AuthlogicController
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  filter_parameter_logging :password, :password_confirmation

  include ApplicationHelper

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "You are not authorized to do that"
    redirect_to login_url
  end
end
