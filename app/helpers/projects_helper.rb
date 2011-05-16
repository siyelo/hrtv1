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
    errors = []

    if project.budget != (project.activities_budget_total + project.other_costs_budget_total)
      errors << "<li>The Projects Budget should match the total budgets for Activities plus Other Costs. Please update your activities/other costs for this project accordingly.</li>"
    end

    if project.spend != (project.activities_spend_total + project.other_costs_spend_total)
      errors << "<li>The Projects Expenditure should match the total expenditures for Activities plus Other Costs. Please update your activities/other costs for this project accordingly.</li>"
    end

    if !project.linked?
      errors << "<li>The Project is not currently linked.</li>"
    end

    if errors
      '<ul class="response-notice">' + errors.join + '</ul>'
    end
  end
end
