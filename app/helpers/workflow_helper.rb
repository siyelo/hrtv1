module WorkflowHelper
  @@map = { "start" => "projects/index", "projects/index" => "funding_flows/funding_sources", "funding_flows/funding_sources" => "funding_flows/providers",
            "funding_flows/providers" => "activities/index" , "activities/index" => "show"}

  def workflow_start
    next_workflow_path "start"
  end

  def next_workflow_path
    '/'+next_workflow_path_wo_slash
  end

  def next_workflow_path_wo_slash
    @@map[current_workflow_url]
  end

  def current_workflow_url
    "#{params[:controller]}/#{params[:action]}"
  end
end
