# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery
  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user

  include ApplicationHelper
  include SslRequirement

  class AccessDenied < StandardError; end
  rescue_from AccessDenied do |exception|
    flash[:error] = "You are not authorized to do that"
    redirect_to login_url
  end

  protected

    # Require SSL for all actions in all controllers
    # redefined method from SSL requirement plugin
    # This method is redefined in static pages controller for actions: :index, :about, :contact, :news
    def ssl_required?
      if Rails.env == "production" || Rails.env == "staging" # || Rails.env == "development"
        true
      else
        false
      end
    end

    def set_layout
      if current_user
        current_user.reporter? ? 'reporter' : 'admin'
      else
        'application'
      end
    end

    def send_csv(text, filename)
      send_data text,
                :type => 'text/csv; charset=iso-8859-1; header=present',
                :disposition => "attachment; filename=#{filename}"
    end

  private

    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user ||= current_user_session && current_user_session.record
      session[:username] = @current_user.username if @current_user
      @current_user
    end

    def require_user
      unless current_user
        store_location
        flash[:error] = "You must be logged in to access this page"
        redirect_to login_url
        return false
      end
    end

    def require_admin
      unless current_user && current_user.admin?
        store_location
        flash[:error] = "You must be an administrator to access that page"
        redirect_to login_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        #flash[:error] = "You must be logged out to access requested page"
        redirect_to user_dashboard_path(current_user)
        return false
      end
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def find_response(response_id)
      if current_user.admin?
        # work-arround until all admin actions are moved to admin controllers
        DataResponse.find(response_id)
      else
        current_user.data_responses.find(response_id)
      end
    end

    def find_project(project_id)
      if current_user.admin?
        Project.find(project_id)
      else
        current_user.current_data_response.projects.find(project_id)
      end
    end

    # Render detailed diagnostics for unhandled exceptions rescued from
    # a controller action.
    def rescue_action_locally(exception)
      class << RESCUES_TEMPLATE_PATH
        def [](path)
          if Rails.root.join("app/views", path).exist?
            ActionView::Template::EagerPath.new_and_loaded(Rails.root.join("app/views").to_s)[path]
          else
            super
          end
        end
      end
      super
    end
end
