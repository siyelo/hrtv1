require 'spec_helper'

describe OrganizationsController do
  before :each do
    @reporter = Factory(:reporter)
    login(@reporter)
  end

  it "redirects to dashboard_path" do
    put :update, :id => :current
    response.should redirect_to edit_organization_url(@reporter.organization)
  end
end
