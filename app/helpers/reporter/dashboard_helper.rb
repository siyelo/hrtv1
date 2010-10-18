module Reporter::DashboardHelper

  def commentable_path(type, commentable, user)
    case type
      when "Project"
        projects_path
      when "FundingFlow"
        if commentable.try(:to) == user.organization
          funding_sources_data_entry_path
        else
          providers_data_entry_path
        end
      when "Activity"
        activities_path
      when "OtherCost"
        other_costs_path
    end
  end

  def commentable_name(type, commentable, user)
    case type
      when "FundingFlow"
        if commentable.try(:to) == user.organization
          type = "Funding Source"
        else
          type = "Implementer"
        end
      when "OtherCost"
        type = "Other Cost"
    end
    type
  end

end
