class ProjectsController < ApplicationController
  @@shown_columns = [:name, :description,  :expected_total]
  @@create_columns = [:name, :description,  :expected_total, :locations]
  @@columns_for_file_upload = @@shown_columns.map {|c| c.to_s} # TODO fix bug, locations for instance won't work

  # _create_from_file partial in the view
  #  directory for that controller
  map_fields :create_from_file,
    @@columns_for_file_upload,
    :file_field => :file
  
  active_scaffold :project do |config|
    config.columns =  @@shown_columns
    list.sorting = {:name => 'DESC'}
    config.nested.add_link("Activities", [:activities])
    
    config.nested.add_link("Comments", [:comments])
    config.columns[:comments].association.reverse = :commentable
    
    config.create.columns = @@create_columns
    config.update.columns = config.create.columns
    config.columns[:name].inplace_edit = true
    config.columns[:description].inplace_edit = true
    config.columns[:description].form_ui = :textarea
    config.columns[:expected_total].inplace_edit = true
    config.columns[:expected_total].label = "Total Budgeted Amount"
    config.columns[:locations].form_ui = :select
    config.columns[:locations].label = "Districts Worked In"
  end
  
  def index

  end

  def create_from_file
    super @@columns_for_file_upload
  end

  def to_label
    @s="Project: "
    if name.nil? || name.empty?
      @s+"<No Name>"
    else
      @s+name
    end
  end
end
