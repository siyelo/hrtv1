module WorkflowHelper
  #TODO write integration test that just walks through these
  # following links and testing for the right active scaffold name heading
<<<<<<< HEAD

  #GR: using AASM will be more concise here. Also we cant use route helpers in this module
  @@map = { "start" => "projects", "projects" => "funding_flows/funding_sources", "funding_flows/funding_sources" => "funding_flows/providers",
=======
  #TODO broken at the funding_flows steps now that removed routes
<<<<<<< HEAD
  @@map = { "start" => "projects/index", "projects/index" => "funding_flows/funding_sources", "funding_flows/index" => "funding_flows/providers",
>>>>>>> 76b2b7a... refactoring broke workflow links, funding_flows need attention
            "funding_flows/providers" => "activities/index" , "activities/index" => "show"}
=======
  @@map = { "start" => "projects/index", "projects/index" => "funding_sources", "funding_sources/index" => "providers",
            "providers/index" => "activities" , "activities/index" => "show"}
>>>>>>> 89eb0b4... nicer routes and workflow

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
