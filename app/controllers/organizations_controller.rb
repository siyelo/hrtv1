class OrganizationsController < ApplicationController
  @@shown_columns = [:name, :type, :raw_type]
  @@create_columns = [:name, :type, :raw_type]
  def self.create_columns
    @@create_columns
  end
  
  @@columns_for_file_upload = @@create_columns.map {|c| c.to_s}
  map_fields :create_from_file,
    @@columns_for_file_upload,
    :file_field => :file
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

  def create_from_file
    super @@columns_for_file_upload
  end
  protected
  
  #to get the edit link to not show up
  def update_authorized?
    authorize! :update, Organization
  end

end
