class Reporter::DashboardController < Reporter::BaseController
  def index
    @responses      = current_user.organization.data_responses.ordered.all
    @comments       = Comment.on_all(current_user.organization).limit(5)
    @user           = current_user
  end
end

