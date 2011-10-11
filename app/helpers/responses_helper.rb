module ResponsesHelper
  def ready(expr)
    expr ? "ready" : "not-ready"
  end

  def other_costs_class
    !@response.other_costs_entered? ? "info" : "ready"
  end

  def projects_class
    ready(@response.projects_entered? &&
    @response.projects_have_activities?)
  end

  def activities_have_splits_class
    ready(@response.activities_have_splits?)
  end

  def data_verification_class
    ready(@response.check_projects_funding_sources_have_organizations?)
  end

  def flag
    @response.submitted? ? "go" : "stop"
  end
end
