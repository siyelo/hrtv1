class DashboardController < ApplicationController
  COMMENT_LIMIT = 25

  ### Filters
  before_filter :require_user
  before_filter :load_comments

  ### Public Methods

  # Load the dashboard with any special conditions detected by user type
  def index
    load_activity_manager if current_user.activity_manager?
    load_requests

    warn_if_not_current_request unless current_user.district_manager?
  end

  protected

    # load Activity Manager-specific dashboard items
    def load_activity_manager
      @organizations = current_user.organizations
      organization_ids = @organizations.map{|o| o.id}
      @approved_orgs = Activity.with_organization.count(:all,
        :conditions =>  ["organization_id in (?) AND
                          data_responses.data_request_id = ? AND
                          am_approved = ?", organization_ids, current_request, true])
      @total_activities = Activity.with_organization.count(:all,
        :conditions =>  ["organization_id in (?) AND
                          data_responses.data_request_id = ?", organization_ids, current_request])
      @recent_responses = DataResponse.find_all_by_data_request_id(current_request,
        :conditions => ["organization_id in (?) AND
                         submitted_at IS NOT NULL", organization_ids],
        :order => 'submitted_at DESC', :limit => 3)
    end


    # Comment loading for all types of users
    def load_comments
      if current_user.sysadmin?
        @comments = Comment.find(:all, :order => 'created_at DESC', :limit => COMMENT_LIMIT,
                                 :include => [:user, :commentable])
      elsif current_user.activity_manager?
        dr_ids = current_user.organizations.map{|o| o.data_responses.map{|dr| dr.id }}.flatten
        dr_ids += current_user.organization.data_responses.map{|dr| dr.id }
        @comments  = Comment.on_all(dr_ids).limit(COMMENT_LIMIT)
      elsif current_user.district_manager?
        @comments = [] # TODO: change this for DM comments
      else
        @comments = Comment.on_all(current_user.organization.data_responses.map{|r| r.id}).limit(COMMENT_LIMIT)
      end
    end

    # Request loading for all types of users
    def load_requests
      @requests = DataRequest.paginate :page => params[:page], :order => 'created_at DESC', :per_page => 5
    end
end
