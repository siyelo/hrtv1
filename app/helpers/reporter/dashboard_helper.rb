module Reporter::DashboardHelper
  def commentable_path(type, commentable, user)
    case type
    when "Project"
      edit_project_path(commentable.id)
    when "FundingFlow"
      edit_funding_flow_path(commentable.id)
    when "Activity"
      edit_activity_path(commentable.id)
    when "OtherCost"
      edit_other_cost_path(commentable.id)
    end
  end

  def commentable_name(type, commentable, user)
    case type
    when "FundingFlow"
      (commentable.try(:to) == user.organization) ?
        "Funding Source" : "Implementer"
    when "OtherCost"
      "Other Cost"
    else
      type
    end
  end

  def model_name(model)
    if model.respond_to?(:name)
      model.try(:name) || "(no title)"
    else
      "(no title)"
    end
  end
end
