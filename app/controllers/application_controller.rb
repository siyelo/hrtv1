# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require "lib/hrt"

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery
  filter_parameter_logging :password, :password_confirmation
  helper_method :current_user_session, :current_user, :current_request

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

    def current_request
      current_user.current_request
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
        flash[:error] = "You must be logged out to access requested page"
        redirect_to root_path
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
        @response = DataResponse.find(response_id)
      elsif current_user.activity_manager?
        # scope by the organizations the AM has access to
        @response = DataResponse.find(response_id,
          :conditions => ["organization_id in (?)", [current_user.organization.id] + current_user.organizations.map{|o| o.id}])
      else
        @response = current_user.data_responses.find(response_id)
      end
      @response
    end

    def load_response
      find_response(params[:response_id])
    end

    # use this if your controller expects :id instead of :response_id
    def load_response_from_id
      find_response(params[:id])
    end

    # deprecated - use load_response
    def load_data_response
      load_response
    end

    def find_organization(org_id)
      if current_user.admin?
        @organization = Organization.find(org_id)
      elsif current_user.activity_manager?
        # scope by the organizations the AM has access to
        @organization = Organization.find(org_id,
          :conditions => ["organization_id in (?)",
                         [current_user.organization.id] + current_user.organizations.map{|o| o.id}])
      else # reporter
        @organization = current_user.organization
      end
      @organization
    end

    def load_organization_from_id
      find_organization(params[:id])
    end

    def find_project(project_id)
      if current_user.admin?
        Project.find(project_id)
      else
        current_user.current_response.projects.find(project_id)
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

    def latest_request_message(request)
      "You are now viewing your data for the latest Request: \"<span class='bold'>#{request.name}</span>\""
    end

    def not_latest_request_message(request)
      "You are now viewing data for the Request: \"<span class='bold'>#{request.name}</span>\".
       All changes made will be saved for this Request.
       Would you like to <a href='#{set_latest_request_path}'>resume editing the latest Request?</a>"
    end

    def warn_if_not_current_request
      unless current_user.current_response_is_latest?
        if current_user.current_request
          flash.now[:warning] = not_latest_request_message(current_user.current_request)
        else
          if current_user.sysadmin?
            flash.now[:warning] = "You do not have a current Request set. Please create/assign a Request."
          else
            raise Hrt::CurrentRequestNotSet
          end
        end
      end
    end

    def change_user_current_response(new_request_id)
      user = current_user
      response = user.responses.find_by_data_request_id(new_request_id)
      if response
        user.data_response_id_current = response.id
        if user.save
          user.reload #otherwise current_response association is stale
          flash[:notice] = latest_request_message(user.current_response.request) if user.current_response_is_latest?
        else
          flash[:error] = "Sorry we could not update your response"
        end
      else
        flash[:error] = "Sorry we could not find that response"
      end
    end
end
