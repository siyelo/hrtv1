module ActivitiesHelper
  def get_funding_sources(projects)
    funding_sources = {}
    projects.each do |project|
      funding_sources[project.id] = funding_sources_options(project.in_flows)
    end
    funding_sources.to_json
  end

  def funding_sources_options(flows)
    flows.map{|ff| [ff.from.try(:name), ff.id]}
  end

  def bulk_edit_activity_path(activity, response)
    if activity.class.eql?(Activity)
      activity.new_record? ? response_activities_path(response) : response_activity_path(response, activity)
    else
      activity.new_record? ? response_other_costs_path(response) : response_other_cost_path(response, activity)
    end
  end
end
