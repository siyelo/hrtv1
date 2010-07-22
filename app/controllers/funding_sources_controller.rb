class FundingSourcesController < ApplicationController
  @@columns_for_file_upload = %w[from organization_text project budget spend_q1 spend_q2 spend_q3 spend_q4]
  map_fields :create_from_file,
    @@columns_for_file_upload,
    :file_field => :file

  def index
    @constraints = { :to => User.current_user.organization.id }
    @label = "Funding Sources"
  end

  def create_from_file
    #TODO change application controller so that it's
    # create_from_file method accepts columns and optional
    # block of constraints, instead of using session
    @constraints = { :to => User.current_user.organization.id }
    super @@columns_for_file_upload, @constraints
  end

  def controller_model_class
    FundingFlow
  end

  def help_model
    ModelHelp.find_by_model_name "FundingSource"
  end

end
