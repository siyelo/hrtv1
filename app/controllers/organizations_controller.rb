class OrganizationsController < Reporter::BaseController
  before_filter :load_organization

  def edit
    @organization.valid? # trigger validation errors
  end

  def update
    if @organization.update_attributes(params[:organization])
      flash[:notice] = "Settings were successfully updated."
      redirect_to dashboard_url
    else
      render :action => :edit
    end
  end

  private
    def load_organization
      @organization = current_user.organization
    end
end

