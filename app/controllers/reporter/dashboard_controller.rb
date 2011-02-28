class Reporter::DashboardController < Reporter::BaseController
  def index
    @requests       = DataRequest.unfulfilled(current_user.organization)
    @data_responses = current_user.data_responses
    @comments       = Comment.on_all(current_user.organization).limit(5)
  end

end

