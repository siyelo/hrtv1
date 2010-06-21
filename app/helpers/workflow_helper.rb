module WorkflowHelper
  @@map = { Project => "funding_flows", FundingFlow => "activities", Activity => "summary" }
  def next_workflow_path current_model
    '/'+@@map[current_model]
  end
end
