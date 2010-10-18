class Reporter::DashboardController < ApplicationController
  before_filter :require_user
  skip_before_filter :load_help

  def show
    @data_requests_unfulfilled = DataRequest.unfulfilled(current_user.organization)
    @data_responses = current_user.data_responses
    @project_comments = Comment.on_projects_for(current_user.organization).last(3)
  end

end

