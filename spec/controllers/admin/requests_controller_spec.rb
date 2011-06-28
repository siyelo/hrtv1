require 'spec_helper'

describe Admin::RequestsController do
  before :each do
    login(Factory.create(:admin))
  end

  it "can delete data_request without data_responses" do
    data_request = Factory.create(:data_request)

    delete :destroy, :id => data_request.id
    flash[:notice].should == "Request was successfully deleted."
    response.should redirect_to(admin_requests_url)
  end
  
  it "can set the Admin's request" do
    @user = Factory(:admin)
    login @user
    @response2 = Factory(:data_response)
    put :set_request, :id => @response2.data_request.id
    response.should redirect_to(admin_dashboard_path)
    @user.reload
    @user.current_request.should == @response2.data_request
  end
end
