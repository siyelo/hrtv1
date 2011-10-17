require File.dirname(__FILE__) + '/../spec_helper'

include ControllerStubs

describe UsersController do
  [:sysadmin, :reporter, :activity_manager].each do |user|
    it "can set the #{user.to_s.humanize}'s request" do
      @organization  = Factory(:organization)
      @data_request  = Factory(:data_request, :organization => @organization)
      @data_response = @organization.latest_response
      @user = Factory(user, :organization => @organization)
      login @user
      @data_response = @organization.latest_response
      @request.env['HTTP_REFERER'] = 'http://test.com/dashboard'
      put :set_request, :id => @data_request.id
      response.should redirect_to('http://test.com/dashboard')
      @user.reload
      @user.current_request.should == @data_request
    end
  end

  it "can set the user's current response to the latest response" do
    user_org = Factory(:organization)
    data_request = Factory(:data_request, :title => "DR1")
    @user = Factory(:sysadmin, :organization => user_org)
    data_request = Factory(:data_request, :title => "DR2")
    user_org.reload
    oldest_data_response = user_org.responses.first
    newest_data_response = user_org.responses.last
    @user.current_response = user_org.responses.first
    @user.save
    login @user
    request.env['HTTP_REFERER'] = "http://test.host/previous/page"
    @user.current_response.should == oldest_data_response
    put :set_latest_request
    @user.reload
    @user.current_response.should == newest_data_response
  end

  it "allows Activity Manager to download the combined workplan" do
    @organization = Factory :organization, :name => "Organization"
    @user = Factory.create(:activity_manager, :organization => @organization)
    @organization = @user.organization
    login @user
    get :activity_manager_workplan
    response.should be_success
    response.header["Content-Type"].should == "application/excel"
    response.header["Content-Disposition"].should == "attachment; filename=combined_workplan.xls"
  end

  it "does not allow other users to download the Activity Manager's combined workplan" do
    user = stub_logged_in_reporter
    user.stub_chain(:data_responses, :find).and_return(@data_response)
    get :activity_manager_workplan
    response.should redirect_to(login_url)
    flash[:error].should == "You must be an activity manager to access that page"
  end
end
