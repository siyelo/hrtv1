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
    ready(@response.projects_have_activities? &&
      @response.activities_without_implementer_splits.empty? &&
      @response.invalid_implementer_splits.empty?)
  end

  def flag
    @response.submitted? ? "go" : "stop"
  end
end
