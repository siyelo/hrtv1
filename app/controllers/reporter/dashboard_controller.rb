class Reporter::DashboardController < Reporter::BaseController

  def index
    @responses      = current_user.data_responses
    @comments       = Comment.on_all(current_user.organization).limit(5)
    # hack to show something dynamic on dashboard
    @projects       = current_user.organization.projects
    @response       = current_user.organization.data_responses.first || DataResponse.new
    # /hack
  end

end

