class Reporter::DashboardController < Reporter::BaseController
  def index
    @responses     = current_user.organization.data_responses.ordered.all
    dr_ids         = current_user.organization.data_responses.map(&:id)
    @comments      = Comment.on_all(dr_ids).limit(5)
    @user          = current_user
    @request       = current_user.current_request
    @organizations = current_user.organizations
    organization_ids = current_user.organizations.map{|o| o.id}
    if current_user.activity_manager?
      @approved_orgs = Activity.with_organization.count(:all,
        :conditions =>  ["organization_id in (?) AND
                          am_approved IS TRUE",
                          organization_ids])
      @total_activities = Activity.with_organization.count(:all,
        :conditions =>  ["organization_id in (?)",
                          organization_ids])
      @recent_responses = DataResponse.find_all_by_data_request_id(current_request,
        :conditions => ["organization_id in (?) AND submitted_at IS NOT NULL", organization_ids],
        :order => 'submitted_at DESC', :limit => 3)

      # Glenn: use this to get comments for activity manager dashboard (after rebase with rw_dev)
      # dr_ids = current_user.organizations.map{|o| o.data_responses.map{|dr| dr.id }}.flatten
      # @comments  = Comment.on_all(dr_ids).limit(5)
    end
  end
end

