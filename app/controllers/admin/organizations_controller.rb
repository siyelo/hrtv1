class Admin::OrganizationsController < ActiveScaffoldController
  layout 'admin'  # duplicated - should inherit from BaseController

  before_filter :require_admin

  authorize_resource


  ### Active Scaffold crud

  @@shown_columns           = [:name, :type]
  @@create_columns          = [:name, :type]
  @@columns_for_file_upload = @@create_columns.map {|c| c.to_s}

  map_fields :create_from_file, @@columns_for_file_upload, :file_field => :file

  active_scaffold :organization do |config|
    config.columns                                 = @@shown_columns
    config.list.pagination                         = true
    config.list.per_page                           = 200
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
    # in nested scaffolds delete just removes the association
    config.nested.shallow_delete = true
  end

  ### Public Class Methods

  def self.create_columns
    @@create_columns
  end

  ### Public Instance Methods

  def show
    @organization = Organization.find(params[:id])

    respond_to do |format|
      format.js {render :partial => 'organization_info'}
    end
  end

  def destroy
    @organization = Organization.find(params[:id])

    if @organization.is_empty?
      @organization.destroy
      render_notice("Organization was successfully deleted.", duplicate_admin_organizations_path)
    else
      render_error("You cannot delete an organization that has users or data associated with it.", duplicate_admin_organizations_path)
    end
  end

  def duplicate
    @organizations_without_users = Organization.without_users.ordered
    @all_organizations = Organization.ordered
  end

  def remove_duplicate
    if params[:duplicate_organization_id].blank? && params[:target_organization_id].blank?
      render_error("Duplicate or target organizations not selected.", duplicate_admin_organizations_path)
    elsif params[:duplicate_organization_id] == params[:target_organization_id]
      render_error("Same organizations for duplicate and target selected.", duplicate_admin_organizations_path)
    else
      duplicate = Organization.find(params[:duplicate_organization_id])
      target = Organization.find(params[:target_organization_id])

      if duplicate.users.size > 0
        render_error("Duplicate organization #{duplicate.name} has users.", duplicate_admin_organizations_path)
      else
        Organization.merge_organizations!(target, duplicate)
        render_notice("Organizations successfully merged.", duplicate_admin_organizations_path)
      end
    end
  end

  protected

    #to get the edit link to not show up
    def update_authorized?
      authorize! :update, Organization
    end

  private

    def render_error(message, path)
      respond_to do |format|
        format.html do
          flash[:error] = message
          redirect_to path
        end
        format.js do
          render :json => {:message => message}.to_json, :status => :partial_content
        end
      end
    end

    def render_notice(message, path)
      respond_to do |format|
        format.html do
          flash[:notice] = message
          redirect_to path
        end
        format.js do
          render :json => {:message => message}.to_json
        end
      end
    end

end
