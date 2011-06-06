module Reporter::DashboardHelper
  def commentable_path(type, commentable, user)
    case type
    when "Project"
      edit_response_project_path(commentable.data_response, commentable.id)
    when "Activity"
      edit_response_activity_path(commentable.data_response, commentable)
    when "OtherCost"
      edit_response_other_cost_path(commentable.data_response, commentable)
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
