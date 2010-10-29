class OrganizationsController < ActiveScaffoldController
  before_filter :require_admin, :only => [:duplicate, :remove_duplicate]

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

  def duplicate
    @potential_duplicate_organiations = Organization.find(:all, 
                                                          :select => "organizations.id, organizations.name, COUNT(users.id) as users_count", 
                                                          :joins => "LEFT OUTER JOIN users ON users.organization_id = organizations.id", 
                                                          :order => "organizations.name ASC",
                                                          :group => "organizations.id HAVING users_count = 0")
    @all_organizations = Organization.find(:all, :select => "id, name", :order => "name ASC")
  end

  def remove_duplicate
    if params[:duplicate_organization_id].blank? && params[:target_organization_id].blank?
      flash[:error] = "Duplicate or target organizations not selected."
      redirect_to duplicate_organizations_path
    elsif params[:duplicate_organization_id] == params[:target_organization_id]
      flash[:error] = "Same organizations for duplicate and target selected."
      redirect_to duplicate_organizations_path
    else
      duplicate = Organization.find(params[:duplicate_organization_id])
      target = Organization.find(params[:target_organization_id])
      if duplicate.users.count > 0
        flash[:error] = "Duplicate organization #{duplicate.name} has users."
        redirect_to duplicate_organizations_path
      else
        Organization.merge_organizations!(target, duplicate)
        flash[:notice] = "Organizations successfully merged."
        redirect_to duplicate_organizations_path
      end
    end
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
