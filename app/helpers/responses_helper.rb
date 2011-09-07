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
    ready(
      @response.check_projects_funding_sources_have_organizations?)
  end

  def link_to_unclassified(activity)
    case
    when !activity.coding_spend_district_classified?
      edit_activity_or_ocost_path(activity, :mode => 'locations')
    when !activity.coding_spend_classified?
      edit_activity_or_ocost_path(activity, :mode => 'purposes')
    when !activity.coding_spend_cc_classified?
      edit_activity_or_ocost_path(activity, :mode => 'inputs')
    when !activity.coding_budget_district_classified?
      edit_activity_or_ocost_path(activity, :mode => 'locations')
    when !activity.coding_budget_classified?
      edit_activity_or_ocost_path(activity, :mode => 'purposes')
    when !activity.coding_budget_cc_classified?
      edit_activity_or_ocost_path(activity, :mode => 'inputs')
    else
      edit_activity_or_ocost_path(activity)
    end
  end
end
