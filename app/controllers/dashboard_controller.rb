class DashboardController < ApplicationController
  COMMENT_LIMIT = 25
  include PrepareCharts

  ### Filters
  before_filter :require_user
  before_filter :load_comments

  ### Public Methods

  # Load the dashboard with any special conditions detected by user type
  def index
    load_activity_manager if current_user.activity_manager? && !current_user.sysadmin?
    load_requests
    warn_if_not_current_request unless current_user.district_manager?
    load_dashboard_charts unless current_user.district_manager? || current_user.sysadmin?
  end

  protected
    # load Activity Manager-specific dashboard items
    def load_activity_manager
      @organizations = current_user.organizations
      organization_ids = @organizations.map{|o| o.id}
      @approved_activities = Activity.only_simple.with_organization.count(:all,
        :conditions =>  ["organization_id in (?) AND
                          data_responses.data_request_id = ? AND
                          am_approved = ?", organization_ids, current_request, true])
      @total_activities = Activity.only_simple.with_organization.count(:all,
        :conditions =>  ["organization_id in (?) AND
                          data_responses.data_request_id = ?", organization_ids, current_request])
      @recent_responses = current_request.data_responses.find(:all,
        :conditions => ["state = ? AND organization_id in (?)",
                        'submitted', organization_ids],
        :order => 'updated_at DESC', :limit => 3)
      @pending_activities = @total_activities - @approved_activities
    end


    # Comment loading for all types of users
    def load_comments
      if current_user.sysadmin?
        @comments = Comment.paginate :all,
                     :order => 'created_at DESC',
                     :include => [:user, :commentable],
                     :per_page => COMMENT_LIMIT, :page => params[:page]
      elsif current_user.activity_manager?
        dr_ids = current_user.organizations.map{|o| o.data_responses.map{|dr| dr.id }}.flatten
        dr_ids += current_user.organization.data_responses.map{|dr| dr.id }
        @comments  = Comment.on_all(dr_ids).
          paginate :per_page => COMMENT_LIMIT, :page => params[:page]
      elsif current_user.district_manager?
        activity_ids = current_user.location.code_assignments.find(:all,
          :select => "DISTINCT(code_assignments.activity_id)").map{|a| a.activity_id}
        @comments = Comment.paginate :all,
          :conditions => ["comments.commentable_type = 'Activity'
                           AND comments.commentable_id IN (?)", activity_ids],
          :per_page => COMMENT_LIMIT, :page => params[:page]
      else
        @comments = Comment.on_all(current_user.organization.data_responses.map{|r| r.id}).
          paginate :per_page => COMMENT_LIMIT, :page => params[:page]
      end
    end

    # Request loading for all types of users
    def load_requests
      @requests = DataRequest.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 5
    end
end
