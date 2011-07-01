module Reporter::DashboardHelper
  def commentable_path(comment, user)
    commentable = comment.commentable
    case comment.commentable_type
    when "Project"
      edit_response_project_path(commentable.data_response, commentable.id)
    when "Activity"
      edit_response_activity_path(commentable.data_response, commentable)
    when "OtherCost"
      edit_response_other_cost_path(commentable.data_response, commentable)
    when "DataResponse"
      response_projects_path(commentable)
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
      model.try(:name).presence || "Unnamed #{model.class.to_s.titleize}"
    else
      "(no title)"
    end
  end
end
