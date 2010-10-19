module ProjectsHelper

  # Active Scaffold fields override
  def start_date_form_column(column, options)
    text_field :record, :start_date, options.merge({:class => "date_picker"})
  end

  def end_date_form_column(column, options)
    text_field :record, :end_date, options.merge({:class => "date_picker"})
  end

  def options_for_association_count association
    if association.name == :comments
      0
    else
      super
    end
  end
end
