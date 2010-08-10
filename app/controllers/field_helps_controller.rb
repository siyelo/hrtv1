class FieldHelpsController < ApplicationController
  authorize_resource
  @@shown_columns = [:model_help, :attribute_name, :short,  :long]
  @@create_columns = @@shown_columns
  def self.create_columns
    @@create_columns
  end
  @@columns_for_file_upload = @@shown_columns.map {|c| c.to_s}

  active_scaffold :field_help do |config|
    config.label = "Help for Fields"
    config.columns =  @@shown_columns
    list.sorting = {:attribute_name => 'DESC'}
    config.create.columns = @@create_columns
    config.update.columns = [:attribute_name, :short, :long]
    config.columns[:short].inplace_edit = true
    config.columns[:short].label = "Help Sidebar Text"
    config.columns[:long].inplace_edit = true
    config.columns[:long].label = "Text Next to Field on Form"
  end

  #add some callback on save that updates the description in 
  #active scaffold config with set_active_scaffold_column_descriptions
end
