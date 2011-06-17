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

  def get_project_errors(project)
    errors = project.try(:errors_from_response)

    if errors.present?
      errors = errors.collect{|e| "<li>#{e}</li>"}
      '<ul class="response-notice">' + errors.join + '</ul>'
    else
      nil # when no errors
    end
  end

  def ordered_locations(locations)
    locations = locations.dup # copy the array, otherwise it removes project locations
    if (central_level = locations.detect{|l| l.short_display == 'Central Level'})
      central_level = locations.delete(central_level)
      locations.unshift(central_level)
    end
    locations
  end
end
