require 'spec_helper'

describe UsersController do
  
  it "can set the Admin's request" do
    @user = Factory(:sysadmin)
    login @user
    request.env['HTTP_REFERER'] = "http://test.host/previous/page"
    data_request = Factory.create(:data_request)
    put :set_request, :id => data_request.id
    @user.reload
    @user.current_request.should == data_request
  end
  
  it "can set the user's current response to the latest response" do
    user_org = Factory(:organization)
    data_request = Factory(:data_request)
    oldest_data_response = Factory(:data_response, :organization => user_org, :data_request => data_request)
    newest_data_response = Factory(:data_response, :organization => user_org, :data_request => data_request)
    @user = Factory(:sysadmin, :current_response => oldest_data_response, :organization => user_org)
    login @user
    request.env['HTTP_REFERER'] = "http://test.host/previous/page"
    @user.current_response.should == oldest_data_response
    put :set_latest_request
    @user.reload
    @user.current_response.should == newest_data_response
  end
end
