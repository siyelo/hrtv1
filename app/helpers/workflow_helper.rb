module WorkflowHelper
  @@map = { "start" => "projects", "projects/index" => "funding_sources", "funding_sources/index" => "providers",
            "providers/index" => "activities" , "activities/index" => "other_costs", "other_costs/index" => "#"}

  def workflow_start
    "/"+@@map["start"]
  end

  def next_workflow_path
    if next_workflow_path_wo_slash
      '/'+next_workflow_path_wo_slash
    else
      '/'
    end
  end

  def next_workflow_path_wo_slash
    @@map[current_workflow_url]
  end

  def current_workflow_url
    "#{params[:controller]}/#{params[:action]}"
  end
end
