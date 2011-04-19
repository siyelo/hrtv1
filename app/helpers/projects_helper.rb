module ProjectsHelper

  # Active Scaffold fields override
  def start_date_form_column(column, options)
    text_field :record, :start_date, options.merge({:class => "date_picker"})
  end

  def end_date_form_column(column, options)
    text_field :record, :end_date, options.merge({:class => "date_picker"})
  end

  def funder_projects_select(from_org)
    flows = []
    funder_projects = from_org.projects.map{|op| [op.name, op.id]}
    [["Please select a project...",""]] +
      funder_projects + [["<Project not listed or unknown>", 0]]
  end

  # this disallows adding existing comments
  def options_for_association_count association
    if association.name == :comments
      0
    else
      super
    end
  end
end
