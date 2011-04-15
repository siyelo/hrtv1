module ProjectsHelper

  # Active Scaffold fields override
  def start_date_form_column(column, options)
    text_field :record, :start_date, options.merge({:class => "date_picker"})
  end

  def end_date_form_column(column, options)
    text_field :record, :end_date, options.merge({:class => "date_picker"})
  end
  
  def funding_flows_select(project)
    flows = [["Project Missing/Unknown", "-1"]]
    flow = []
    project.in_flows.each do |in_flow|
      flow = in_flow.from.projects.map{|op| [op.name, op.id]}
    end
    flows = flows | flow
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
