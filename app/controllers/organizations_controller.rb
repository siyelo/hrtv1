class OrganizationsController < ApplicationController
  @@shown_columns = [:name, :type]
  @@create_columns = [:name]
  
  active_scaffold :organization do |config|
    config.columns =  @@shown_columns
    list.sorting = {:name => 'DESC'}

    config.create.columns = @@create_columns
    config.update.columns = config.create.columns
  end
end
