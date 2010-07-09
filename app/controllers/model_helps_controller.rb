class ModelHelpsController < ApplicationController
  @@shown_columns = [:model_name, :short,  :long]
  @@create_columns = @@shown_columns

  active_scaffold :model_help do |config|
    config.label = "Help for Pages and Data Fields"
    config.columns =  @@shown_columns
    list.sorting = {:model_name => 'DESC'}
    config.nested.add_link("Comments", [:comments])
    config.columns[:comments].association.reverse = :commentable
    config.nested.add_link("Field Help", [:field_help])

    config.columns[:short].inplace_edit = true
    config.columns[:long].inplace_edit = true
    config.create.columns = @@create_columns
    config.update.columns = [:short, :long]
  end

end
