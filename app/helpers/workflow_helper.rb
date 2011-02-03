module WorkflowHelper

  def next_workflow_path
    case "#{params[:controller]}/#{params[:action]}"
    when "data_responses/start"
      projects_path
    when "projects/index"
      funding_sources_path
    when "funding_sources/index"
      implementers_path
    when "implementers/index"
      activities_path
    when "activities/index"
      other_costs_path
    when "other_costs/index"
      review_data_response_path(current_user.current_data_response)
    else
      root_path
    end
  end
end
