module Reporter::DashboardHelper

  def commentable_path(type, commentable, user)
    case type
      when "Project"
        edit_project_path commentable.id
      when "FundingFlow"
        #if commentable.try(:to) == user.organization
          #funding_sources_data_entry_path
          edit_funding_flow_path commentable.id
        #else
        #  providers_data_entry_path
        #end
      when "Activity"
        edit_activity_path commentable.id
      when "OtherCost"
        edit_other_cost_path commentable.id
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
