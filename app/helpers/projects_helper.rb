module ProjectsHelper
  def funder_projects_select(from_org, project_id)
    flows = []
    funder_projects = from_org.projects.map{|op| [op.name, op.id] if op.id != project_id}.compact
    [["Please select a project...",""]] +
      funder_projects + [["<Project not listed or unknown>", 0]]
  end
end
