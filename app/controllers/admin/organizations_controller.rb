class Admin::OrganizationsController < ApplicationController
  before_filter :require_admin

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
    @potential_duplicate_organiations = Organization.find(:all, 
                                                          :select => "organizations.id, organizations.name, organizations.created_at, COUNT(users.id) as users_count", 
                                                          :joins => "LEFT OUTER JOIN users ON users.organization_id = organizations.id", 
                                                          :order => "organizations.name ASC, organizations.created_at DESC",
                                                          :group => "organizations.id, organizations.name, organizations.created_at",
                                                          :having => "COUNT(users.id) = 0")
    @all_organizations = Organization.find(:all, 
                                           :select => "id, name, created_at, (SELECT COUNT(users.id) FROM users WHERE users.organization_id = organizations.id) AS users_count", 
                                           :order => "name ASC, created_at DESC")
  end

  def remove_duplicate
    if params[:duplicate_organization_id].blank? && params[:target_organization_id].blank?
      render_error("Duplicate or target organizations not selected.", duplicate_admin_organizations_path)

    elsif params[:duplicate_organization_id] == params[:target_organization_id]
      render_error("Same organizations for duplicate and target selected.", duplicate_admin_organizations_path)

    else
      duplicate = Organization.find(params[:duplicate_organization_id])
      target = Organization.find(params[:target_organization_id])

      if duplicate.users.count > 0
        render_error("Duplicate organization #{duplicate.name} has users.", duplicate_admin_organizations_path)
      else
        Organization.merge_organizations!(target, duplicate)
        render_notice("Organizations successfully merged.", duplicate_admin_organizations_path)
      end
    end
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
