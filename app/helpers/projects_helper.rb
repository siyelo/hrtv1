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
  
  def get_project_total_differences(project)  
    errors = []
    if (project.spend || 0) - project.subtotals(:spend) > 0 
      errors << "Past expenditure difference: #{n2cndrs((project.spend || 0) - project.subtotals(:spend), project.currency)}"
    end
    
    if (project.budget || 0) - project.subtotals(:budget) > 0 
      errors << "Current budget difference: #{n2cndrs((project.budget || 0) - project.subtotals(:budget), project.currency)}"
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
