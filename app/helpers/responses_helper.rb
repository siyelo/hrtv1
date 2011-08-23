module ResponsesHelper
  def ready(expr)
    expr ? "ready" : "not-ready"
  end

  def your_projects_class
    ready(@response.projects_entered? &&
    @response.projects_have_activities? &&
    @response.projects_have_other_costs?)
  end

  def projects_linked_class
    if @response.request.final_review?
      return ready(@response.projects_linked?)
    else
      return @response.projects_linked? ? "ready" : "info"
    end
  end

  def data_verification_class
    ready(@response.projects_linked? &&
      @response.check_projects_funding_sources_have_organizations? &&
      @response.activities_have_implementers? &&
      @response.projects_funding_sources_ok?)
  end
end
