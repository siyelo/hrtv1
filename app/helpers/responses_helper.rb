module ResponsesHelper

  def ready(expr)
    expr ? "ready" : "not-ready"
  end

  def your_projects
    ready(@response.projects_entered? &&
    @response.project_amounts_entered? &&
    @response.projects_have_activities? &&
    @response.projects_have_other_costs?)
  end

  def projects_entered
    ready(@response.projects_entered?)
  end

  def project_amounts_entered
    ready(@response.project_amounts_entered?)
  end

  def projects_have_activities
    ready(@response.projects_have_activities?)
  end

  def projects_have_other_costs
    ready(@response.projects_have_other_costs?)
  end

  def detailed_classification
    ready(@response.activities_coded? &&
    @response.other_costs_coded?)
  end

  def activities_coded
    ready(@response.activities_coded?)
  end

  def final_review
    @response.request.final_review?
  end

  def projects_linked
    @response.projects_linked?
  end

  def projects_linked_class
    if final_review
      return ready(projects_linked)
    else
      return projects_linked ? "ready" : "info"
    end
  end

  def other_costs_coded
    ready(@response.other_costs_coded?)
  end

  def data_verification
    ready(@response.projects_and_funding_sources_have_matching_budgets? &&
    @response.projects_and_funding_sources_have_correct_spends? &&
    @response.projects_and_activities_have_matching_budgets? &&
    @response.projects_and_activities_have_matching_spends? &&
    projects_linked_class)
  end

  def projects_funding_sources_ok
    @response.projects_and_funding_sources_have_matching_budgets? &&
    @response.projects_and_funding_sources_have_correct_spends?
  end

  def projects_activities_ok
    @response.projects_and_activities_have_matching_budgets? &&
    @response.projects_and_activities_have_matching_spends?
  end

  def projects_funders_have_organizations
    ready(@response.check_projects_funding_sources_have_organizations?)
  end

  def activities_have_implementers
    ready(@response.activities_have_implementers?)
  end
end
