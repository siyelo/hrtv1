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
end
