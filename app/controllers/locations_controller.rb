class LocationsController < ApplicationController
  @@shown_columns = [:short_display]
  @@create_columns = [:short_display]
  
  active_scaffold :location do |config|
    config.columns =  @@shown_columns
    list.sorting = {:short_display => 'DESC'}

    config.create.columns = @@create_columns
    config.update.columns = config.create.columns
  end

end
