class ActivityCostCategoriesController < ApplicationController
  @@shown_columns = [:short_display]
  @@create_columns = [:short_display]
  
  active_scaffold :activity_cost_category do |config|
    config.columns =  @@shown_columns
    list.sorting = {:short_display => 'DESC'}
    config.label = "Cost Category Detail"

    config.create.columns = @@create_columns
    config.update.columns = config.create.columns
  end

end
