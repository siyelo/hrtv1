class OrganizationsController < Reporter::BaseController

  def edit
    @organization = current_user.organization
    @organization.valid? # trigger validation errors
  end

  def update
    @organization = current_user.organization
    @organization.update_attributes(params[:organization])
    if @organization.save
      flash[:notice] = "Successfully updated."
      redirect_to edit_organization_url(@organization)
    else
      render :action => :edit
    end
  end
end

