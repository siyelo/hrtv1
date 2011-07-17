require File.dirname(__FILE__) + '/../spec_helper'

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
end
