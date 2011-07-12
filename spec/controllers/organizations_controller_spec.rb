require 'spec_helper'

describe OrganizationsController do
  before :each do
    @reporter = Factory.create(:reporter)
    login(@reporter)
  end

  it "redirects to dashboard_path" do
    put :update, :id => :current
    response.should redirect_to(dashboard_path)
  end
end
