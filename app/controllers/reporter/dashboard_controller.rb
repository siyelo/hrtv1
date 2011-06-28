class Reporter::DashboardController < Reporter::BaseController
  def index
    @responses = current_user.organization.data_responses.ordered.all
    dr_ids     = current_user.organization.responses.map(&:id)
    @comments  = Comment.on_all(dr_ids).limit(5)
    @user      = current_user
  end
end

