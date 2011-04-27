module ProjectsHelper

  def funder_projects_select(from_org, project_id)
    if from_org
      funder_projects = from_org.projects.select{|op| [op.name, op.id] if op.id != project_id}
    else
      funder_projects = []
    end

    options = [["Please select a project...", ""]]
    options.concat(funder_projects)
    options << ["<Project not listed or unknown>", 0]

    options
  end
end
