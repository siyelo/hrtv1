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
  
  def export
    if params[:type] == 'NGO'
      organizations = Organization.with_type("Donors").ordered + Organization.with_type("NGO").ordered
    elsif params[:type] == 'centers'
      organizations = Organization.with_type("District Hospital").ordered + Organization.with_type("Health Center").ordered
    else 
      organizations = Organization.ordered
    end
    template = Organization.download_template(organizations)
    send_csv(template, 'organizations.csv')
  end

  private
    def load_organization
      @organization = current_user.organization
    end
end

