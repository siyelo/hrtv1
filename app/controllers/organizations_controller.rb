class OrganizationsController < Reporter::BaseController
  before_filter :load_organization_from_id

  def edit
    @organization.valid? # trigger validation errors
  end

  def update
    @organization.update_attributes(params[:organization])
    if @organization.save
      flash[:notice] = "Successfully updated."
      redirect_to edit_organization_url(@organization)
    else
      render :action => :edit
    end
  end
end

