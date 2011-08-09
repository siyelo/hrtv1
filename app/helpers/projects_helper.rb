module ProjectsHelper

  def funder_projects_select(from_org, project_id)
    if from_org
      funder_projects = from_org.projects.select{ |op| op.id != project_id }.map{ |op| [op.name, op.id] }
    else
      funder_projects = []
    end

    options = [["Please select a project...", ""]]
    options.concat(funder_projects)
    options << ["<Project not listed or unknown>", 0]
    options
  end

  def format_errors(errors)
    "<ul class='response-notice'>#{errors.map{|e| "<li>#{e}</li>"}.join}</ul>"
  end

  def get_project_total_differences(project)
    errors = []
    if (project.spend || 0) - project.subtotals(:spend) != 0
      errors << "The Project's past expenditure (#{n2cndrs((project.spend || 0), project.currency)}) should match
                the total past expenditure for Activities plus Other Costs (#{n2cndrs(project.subtotals(:spend), project.currency)}).
                Currently there is a difference of #{n2cndrs((project.spend || 0) - project.subtotals(:spend), project.currency)} -
                please update the past expenditure of activities/other costs for this project accordingly."
    end

    if (project.budget || 0) - project.subtotals(:budget) != 0
      errors << "The Project's Current Budget (#{n2cndrs((project.budget || 0), project.currency)}) should match
                the total current budget for Activities plus Other Costs (#{n2cndrs(project.subtotals(:budget), project.currency)}).
                Currently there is a difference of #{n2cndrs((project.budget || 0) - project.subtotals(:budget), project.currency)} -
                please update the current budget of activities/other costs for this project accordingly."
    end

    errors = errors.collect{|e| "<li>#{e}</li>"}
    '<ul class="response-notice">' + errors.join + '</ul>'
  end

  def ordered_locations(locations)
    locations = locations.dup # copy the array, otherwise it removes project locations
    if (central_level = locations.detect{|l| l.short_display == 'National Level'})
      central_level = locations.delete(central_level)
      locations.unshift(central_level)
    end
    locations
  end
end
