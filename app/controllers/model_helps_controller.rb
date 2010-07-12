class ModelHelpsController < ApplicationController
  @@shown_columns = [:model_name,  :long]
  @@create_columns = @@shown_columns

  active_scaffold :model_help do |config|
    config.label = "Help for Pages and Data Fields"
    config.columns =  @@shown_columns
    list.sorting = {:model_name => 'DESC'}
    config.nested.add_link("Comments", [:comments])
    config.columns[:comments].association.reverse = :commentable
    config.nested.add_link("Field Descriptions", [:field_help])

    #config.columns[:short].label = "Currently Unused"
    config.columns[:long].inplace_edit = true
    config.columns[:long].label = "Top of Page Text"
    config.create.columns = @@create_columns
    config.update.columns = [ :long]
  end

end
