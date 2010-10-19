class Reporter::DashboardController < ApplicationController
  before_filter :require_user
  skip_before_filter :load_help

  def show
    @data_requests_unfulfilled = DataRequest.unfulfilled(current_user.organization)
    @data_responses            = current_user.data_responses
    project_comments           = Comment.on_projects_for(current_user.organization)
    funding_source_comments    = Comment.on_funding_sources_for(current_user.organization)
    implementer_comments       = Comment.on_implementers_for(current_user.organization)
    activity_comments          = Comment.on_activities_for(current_user.organization)
    other_cost_comments        = Comment.on_other_costs_for(current_user.organization)
    @comments = (project_comments | funding_source_comments | implementer_comments | activity_comments | other_cost_comments).sort_by(&:created_at).reverse.first(5)
  end

end

