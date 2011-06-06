class OrganizationsController < ApplicationController
  def create
    organization = Organization.new
    organization.name = params[:name]
    organization.save
    respond_to do |format|
      format.js {render :json => organization.to_json}
    end
  end
end

