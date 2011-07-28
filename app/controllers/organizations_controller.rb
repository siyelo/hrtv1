class OrganizationsController < Reporter::BaseController
  before_filter :load_organization

  before_filter :load_organization

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
  
  private
    def load_organization
      @organization = current_user.organization
    end
end
