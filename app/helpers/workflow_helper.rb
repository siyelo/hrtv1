module WorkflowHelper
  @@map = { "data_responses/start" => "projects", "projects/index" => "funding_sources", "funding_sources/index" => "providers",
            "providers/index" => "activities" , "activities/index" => "other_costs", "other_costs/index" => "submit"}

  # deprecated, replaced by clicking on data response first
  #def workflow_start response_id
  #  session[:data_response] = response_id
  #  "/"+@@map["start"]
  #end

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
