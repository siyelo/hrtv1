class OrganizationsController < ActiveScaffoldController
  authorize_resource

  @@shown_columns           = [:name, :type]
  @@create_columns          = [:name, :type]
  @@columns_for_file_upload = @@create_columns.map {|c| c.to_s}

  map_fields :create_from_file, @@columns_for_file_upload, :file_field => :file

  active_scaffold :organization do |config|
    config.columns                                 = @@shown_columns
    list.sorting                                   = {:name => 'DESC'}
    config.columns[:out_flows].association.reverse = :from
    config.columns[:in_flows].association.reverse  = :to
    config.create.columns                          = @@create_columns
    config.update.columns                          = config.create.columns
    config.subform.columns                         = [:name, :type]
    config.columns[:name].description              = "Before creating a new organization, ensure this organization doesn't already exist by checking the drop down list in the create or add existing form."
    config.columns[:type].form_ui                  = :select
    config.columns[:type].options                  = {:options => [
                                                      ["Donor","Donor"],
                                                      ["NGO","Ngo"],
                                                     ["Other", "Organization"] ]}
     config.nested.shallow_delete = true # in nested scaffolds delete just removes the association
  end

  def create_from_file
    super @@columns_for_file_upload
  end

  def self.create_columns
    @@create_columns
  end

  protected

  #to get the edit link to not show up
  def update_authorized?
    authorize! :update, Organization
  end

  # put this in as temporary bug fix
  # if you click institutions assisted on activity screen
  # and delete an activity there, it actually delete's the real
  # organization! until we work around it
  # this makes the delete link not show up there
#  def delete_authorized?
#    authorize! :delete, Organization
#  end

end
