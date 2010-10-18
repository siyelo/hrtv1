class Reporter::DashboardController < ApplicationController
  skip_before_filter :load_help

  before_filter :require_user

  def show
    @data_requests_unfulfilled = DataRequest.unfulfilled(current_user.organization)
    @data_responses = current_user.data_responses
  end

end

