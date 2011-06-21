class OrganizationsController < Reporter::BaseController

  def create
    organization = Organization.new
    organization.name = params[:name]
    organization.save
    respond_to do |format|
      format.js {render :json => organization.to_json}
    end
  end

  def edit
    @organization = current_user.organization
    current_user.current_data_response = @organization.data_responses.first
    current_user.save
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

