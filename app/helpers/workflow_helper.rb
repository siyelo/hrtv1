module WorkflowHelper
  @@map = { Project => "funding_flows", FundingFlow => "activities", Activity => "summary" }

  def next_workflow_path current_model
    '/'+next_workflow_path_wo_slash(current_model)
  end

  def next_workflow_path_wo_slash current_model
    @@map[current_model]
  end

end
