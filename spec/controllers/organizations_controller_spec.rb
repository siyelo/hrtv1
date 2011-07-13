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
  
  it "downloads csv template" do
    Organization.should_receive(:download_template).and_return('csv')
    get :export
    response.should be_success
    response.header["Content-Type"].should == "text/csv; charset=iso-8859-1; header=present"
    response.header["Content-Disposition"].should == "attachment; filename=organizations.csv"
  end
end
