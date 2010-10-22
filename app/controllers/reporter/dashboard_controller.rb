class Reporter::DashboardController < ApplicationController
  before_filter :require_user
  skip_before_filter :load_help

  def index
    @data_requests_unfulfilled = DataRequest.unfulfilled(current_user.organization)
    @data_responses            = current_user.data_responses
    @comments                  = Comment.on_all(current_user.organization, 5)
  end
  
  def reports
    @data_responses            = current_user.data_responses
  end
end

