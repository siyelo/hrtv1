class Reporter::DashboardController < Reporter::BaseController

  def index
    @requests       = current_user.organization.unfulfilled_data_requests
    @data_responses = current_user.data_responses
    @comments       = Comment.on_all(current_user.organization).limit(5)
  end
end

