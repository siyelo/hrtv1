require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  [:sysadmin, :reporter, :activity_manager].each do |user|
    it "can set the #{user.to_s.humanize}'s request" do
      @user = Factory(user)
      login @user
      @response2 = Factory(:data_response)
      @request.env['HTTP_REFERER'] = 'http://test.com/dashboard'
      put :set_request, :id => @response2.data_request.id
      response.should redirect_to('http://test.com/dashboard')
      @user.reload
      @user.current_request.should == @response2.data_request
    end
  end
end
