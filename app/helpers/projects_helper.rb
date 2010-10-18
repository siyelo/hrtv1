module ProjectsHelper

  # Active Scaffold fields override
  def start_date_form_column(column, options)
    text_field :record, :start_date, options.merge({:class => "date_picker"})
  end

  def end_date_form_column(column, options)
    text_field :record, :end_date, options.merge({:class => "date_picker"})
  end
end
