class FundingSourcesController < ApplicationController
  @@columns_for_file_upload = %w[from project ]
  map_fields :create_from_file,
    @@columns_for_file_upload,
    :file_field => :file

  def index
    @constraints = { :to => Organization.last.id } #current_user.organization.id
    @label = "Funding Sources"
  end

  def create_from_file
    #TODO change application controller so that it's
    # create_from_file method accepts columns and optional
    # block of constraints, instead of using session
    @constraints = { :from => Organization.last.id } #current_user.organization.id
    session[:last_data_entry_constraints] = @constraints
    super @@columns_for_file_upload
  end
end
