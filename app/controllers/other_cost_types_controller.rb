class OtherCostTypesController < ApplicationController
  @@shown_columns = [:short_display]
  @@create_columns = [:short_display]
  
  active_scaffold :other_cost_types do |config|
    config.columns =  @@shown_columns
    list.sorting = {:short_display => 'DESC'}
    config.label = "Other Cost Type"

    config.create.columns = @@create_columns
    config.update.columns = config.create.columns
  end
end
