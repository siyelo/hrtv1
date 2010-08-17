# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < AuthlogicController
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  filter_parameter_logging :password, :password_confirmation

  include ApplicationHelper

  rescue_from CanCan::AccessDenied do |exception|
      render :text => "Sorry, you do not have permission for this action or you have been logged out.
      You may login at #{root_url} or use the contact link at
      the bottom of the homepage to contact an administrator, if you
      think this message is being shown in error."
      # TODO try the below to see if inf loop bug is still there
      # render a template / action without the layout with login link & help msg
      # redirect caused infinite loop, could be that home page had security on it
      #flash[:error] = "Access denied!"
      #redirect_to root_url
  end
end
