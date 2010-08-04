class ProjectsController < ApplicationController
  authorize_resource

  before_filter :check_user_has_data_response

  @@shown_columns = [:name, :description,  :budget, :spend]
  @@create_columns = [:name, :description, :currency, :entire_budget, :budget, :spend,  :start_date, :end_date, :locations]
  @@upload_columns = [:name, :description, :currency, :entire_budget, :budget, :spend,  :start_date, :end_date ]
  def self.create_columns
    @@create_columns
  end
  @@columns_for_file_upload = @@upload_columns.map {|c| c.to_s} # TODO fix bug, >1 location won't work

 # record_select :per_page => 20, :search_on => 'name', :order_by => "name ASC"

  map_fields :create_from_file,
    @@columns_for_file_upload,
    :file_field => :file

  active_scaffold :projects do |config|
    config.columns =  @@shown_columns
    list.sorting = {:name => 'DESC'}
    config.nested.add_link("Activities", [:activities])

    config.nested.add_link("Comments", [:comments])
    config.columns[:comments].association.reverse = :commentable

    config.create.columns = @@create_columns
    config.update.columns = config.create.columns
    config.columns[:name].inplace_edit = true
    config.columns[:description].inplace_edit = true
    config.columns[:locations].form_ui = :select
    config.columns[:locations].label = "Districts Worked In"
    config.columns[:currency].label = "Currency (if different)"
    config.columns[:entire_budget].label = "Total Project Budget"
    config.columns[:budget].label = "Total Budget GOR FY 10-11"
    config.columns[:spend].label = "Total Spend GOR FY 09-10"
    [:spend, :budget, :entire_budget].each do |c|
      quarterly_amount_field_options config.columns[c]
      config.columns[c].inplace_edit = true
    end
  end


  def create_from_file
    super @@columns_for_file_upload
  end

end
