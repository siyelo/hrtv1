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
  include Exporter

  class AccessDenied < StandardError; end
  rescue_from AccessDenied do |exception|
    flash[:error] = "You are not authorized to do that"
    redirect_to login_url
  end

  rescue_from ActionController::MethodNotAllowed, :with => :invalid_method

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

  private

    def invalid_method
      flash[:error] = "I'm sorry, that page is not available"
      redirect_to root_url
    end

    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user ||= current_user_session && current_user_session.record
      session[:email] = @current_user.email if @current_user
      @current_user
    end

    def check_activity_manager_permissions(org)
      if cannot_edit_resource?(org)
        flash[:error] = "You do not have permission to edit this resource"
        return false
      end
      true
    end

    ## for any resource dependant on projects and activities
    def can_edit_resource?(org)
      return true if current_user.sysadmin?
      !current_user.activity_manager? ||
      (current_user.reporter? && current_user.organization.eql?(org))
    end

    def cannot_edit_resource?(org)
      !can_edit_resource?(org)
    end

    def current_request
      if current_user.district_manager?
        district_manager_current_request
      else
        current_user.current_request
      end
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
      unless current_user && current_user.sysadmin?
        store_location
        flash[:error] = "You must be an administrator to access that page"
        redirect_to login_url
        return false
      end
    end

    def require_activity_manager
      unless current_user && current_user.activity_manager?
        store_location
        flash[:error] = "You must be an activity manager to access that page"
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
      if current_user.sysadmin?
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
      if current_user.sysadmin?
        @organization = Organization.reporting.find(org_id)
      elsif current_user.activity_manager?
        # scope by the organizations the AM has access to
        @organization = Organization.reporting.find(org_id,
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
      if current_user.sysadmin?
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

    def request_message(request)
      "You are now viewing your data for the Request: \"<span class='bold'>#{request.name}</span>\""
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

    def load_comment_resources(resource)
      @comment = Comment.new
      @comment.commentable = resource
      @comments = resource.comments.find(:all,
         :order => 'created_at DESC',
         :conditions => ['parent_id is NULL AND created_at > ?', DateTime.now - 6.months],
         :include => :user)
      # @comments = resource.comments.roots.find(:all)
      # :include => {:user => :organization} does not work when using roots scope
      # Comment.send(:preload_associations, @comments, {:user => :organization})
    end

    def district_manager_current_request
      if session[:request_id].present?
        DataRequest.find(session[:request_id])
      else
        current_request = DataRequest.find(:first, :order => 'id DESC')
        session[:request_id] ||= current_request.id
        current_request
      end
    end

    def load_klasses(field = :id) #TODO: deprecate id field - use only :mode
      @budget_klass, @spend_klass = case params[field]
      when 'purposes'
        [CodingBudget, CodingSpend]
      when 'inputs'
        [CodingBudgetCostCategorization, CodingSpendCostCategorization]
      when 'locations'
        [CodingBudgetDistrict, CodingSpendDistrict]
      else
        raise "Invalid type #{params[field]}".to_yaml
      end
    end

    def load_klasses_from_mode
      load_klasses(:mode)
    end

    # http://stackoverflow.com/questions/4244507/headers-in-rails-cache-firefox-impropriety
    def prevent_browser_cache
      headers["Pragma"] = "no-cache"
      headers["Cache-Control"] = "must-revalidate"
      headers["Cache-Control"] = "no-cache"
      headers["Cache-Control"] = "no-store"
    end

    def warn_if_not_classified(outlay)
      type = outlay.class.to_s.titleize
      check_delayed_jobs_for(outlay)

      if outlay.approved? || outlay.am_approved?
        flash.now[:error] = "Classification for approved activity cannot be changed." unless flash[:error]
      elsif !outlay.classified?
        if flash[:warning].blank? && ( session['flash'].blank? ||
          session['warning'].present? && session['warning'][:notice].blank? )
          flash.now[:warning] = "This #{type} has not been fully classified.
            #{"<a href=\"#\" rel=\"#uncoded_overlay\" class=\"overlay\">Click here</a>
            to see what still needs to be classified"}"
        end
      else
        if flash[:notice].blank? && ( session['flash'].blank? ||
            session['flash'].present? && session['flash'][:notice].blank? )
          flash.now[:notice] = "This #{type} has been fully classified."
        end
      end
    end

    def check_delayed_jobs_for(outlay)
      dj = Delayed::Job.find(:first,
        :conditions => "handler LIKE '%object: LOAD;#{outlay.class.to_s};#{outlay.id}\nmethod: :update_classified_amount_cache_without_delay%'")

      if dj
        flash.now[:warning] = "We are still busy processing changes to the
          classification tree. Please reload the page to see whether this
          #{outlay.class.to_s.titleize} has been
          fully classified."
      end
    end

    def paginate_splits(outlay)
      @split_errors = outlay.implementer_splits.select{|is| !is.errors.empty?} unless outlay.errors.empty?
      unless @split_errors
        @splits = outlay.implementer_splits.sorted.paginate(:per_page => 50, :page => params[:page]) || outlay.implementer_splits
      end
    end
end
