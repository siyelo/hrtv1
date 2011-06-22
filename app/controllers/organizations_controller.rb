class OrganizationsController < Reporter::BaseController

  def edit
    @organization = current_user.organization
    @organization.valid? # trigger validation errors
    data_response = params[:data_response_id].present? ? @organization.data_responses.find(params[:data_response_id]) : @organization.data_responses.first
    current_user.current_data_response = data_response
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

