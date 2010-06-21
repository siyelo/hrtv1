class FieldHelpsController < ApplicationController
  @@shown_columns = [:model_help, :attribute_name, :short,  :long]
  @@create_columns = @@shown_columns
  
  active_scaffold :field_help do |config|
    config.columns =  @@shown_columns
    list.sorting = {:attribute_name => 'DESC'}
    
    config.create.columns = @@create_columns
    config.update.columns = [:short, :long]
    config.columns[:short].inplace_edit = true
    config.columns[:long].inplace_edit = true
  end
end
