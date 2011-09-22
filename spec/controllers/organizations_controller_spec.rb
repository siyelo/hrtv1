require 'spec_helper'

shared_examples_for 'an organization controller' do
  it "should allow admin to edit settings of reporting organization" do
    o = Factory :organization
    get :edit, :id => o.id
    response.should be_success
  end
  it "should allow admin to edit settings of nonreporting org" do
    o = Factory :organization, :raw_type => 'Communal FOSA'
    get :edit, :id => o.id
    response.should be_success
  end
end

describe OrganizationsController do
  context "as a reporter" do
    before :each do
      login(Factory(:reporter))
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

    it_should_behave_like 'an organization controller'
  end

  context "as a sysadmin" do
    before :each do
      login(Factory(:admin))
    end

    it_should_behave_like 'an organization controller'
  end
end
