class Reporter::ReportsController < Reporter::BaseController

  def index
    @data_responses            = current_user.data_responses
  end
end
