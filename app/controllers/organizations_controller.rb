class OrganizationsController < ApplicationController
  @@shown_columns = [:name, :type, :raw_type]
  @@create_columns = [:name, :type, :raw_type]
  def self.create_columns
    @@create_columns
  end
  
  #record_select :per_page => 20, :search_on => [:name], :order_by => 'name ASC', :full_text_search => true
  
  active_scaffold :organization do |config|
    config.columns =  @@shown_columns
    list.sorting = {:name => 'DESC'}
    config.columns[:out_flows].association.reverse = :from
    config.columns[:in_flows].association.reverse = :to

    config.create.columns = @@create_columns
    config.update.columns = config.create.columns
    config.subform.columns = [:name, :type]
    config.columns[:type].form_ui = :select
    config.columns[:type].options = {:options => [
      ["Donor","Donor"],
      ["NGO","Ngo"],
      ["Other", "Organization"] ]}
  end

end
