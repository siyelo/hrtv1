class OrganizationsController < ApplicationController
  @@shown_columns = [:name, :type, :raw_type]
  @@create_columns = [:name, :type, :raw_type]
  
  record_select :per_page => 20, :search_on => [:name], :order_by => 'name ASC', :full_text_search => true
  
  active_scaffold :organization do |config|
    config.columns =  @@shown_columns
    list.sorting = {:name => 'DESC'}

    config.create.columns = @@create_columns
    config.update.columns = config.create.columns
  end

end
