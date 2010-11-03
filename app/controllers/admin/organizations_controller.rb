class Admin::OrganizationsController < ApplicationController
  before_filter :require_admin

  def show
    @organization = Organization.find(params[:id])

    respond_to do |format|
      format.js {render :partial => 'organization_info'}
    end
  end

  def duplicate
    @potential_duplicate_organiations = Organization.find(:all, 
                                                          :select => "organizations.id, organizations.name, organizations.created_at, COUNT(users.id) as users_count", 
                                                          :joins => "LEFT OUTER JOIN users ON users.organization_id = organizations.id", 
                                                          :order => "organizations.name ASC, organizations.created_at DESC",
                                                          :group => "organizations.id HAVING users_count = 0")
    @all_organizations = Organization.find(:all, :select => "id, name, created_at", :order => "name ASC, created_at DESC")
  end

  def remove_duplicate
    # how do we keep the replacement org selected even after succesful
    # replacement
    if params[:duplicate_organization_id].blank? && params[:target_organization_id].blank?
      flash[:error] = "Duplicate or target organizations not selected."
      redirect_to duplicate_admin_organizations_path
    elsif params[:duplicate_organization_id] == params[:target_organization_id]
      flash[:error] = "Same organizations for duplicate and target selected."
      redirect_to duplicate_admin_organizations_path
    else
      duplicate = Organization.find(params[:duplicate_organization_id])
      target = Organization.find(params[:target_organization_id])
      if duplicate.users.count > 0
        flash[:error] = "Duplicate organization #{duplicate.name} has users."
        redirect_to duplicate_admin_organizations_path
      else
        Organization.merge_organizations!(target, duplicate)
        flash[:notice] = "Organizations successfully merged."
        redirect_to duplicate_admin_organizations_path
      end
    end
  end

end
