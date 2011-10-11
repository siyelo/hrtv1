module ResponsesHelper
  def ready(expr)
    expr ? "ready" : "not-ready"
  end

  def other_costs_class(data_response)
    !data_response.other_costs_entered? ? "info" : "ready"
  end

  def projects_class
    ready(@response.projects_entered? &&
    @response.projects_have_activities?)
  end

  def projects_linked_class
    if @response.request.final_review?
      return ready(@response.projects_linked?)
    else
      return @response.projects_linked? ? "ready" : "info"
    end
  end

  def flag
    @response.submitted? ? "go" : "stop"
  end
end
