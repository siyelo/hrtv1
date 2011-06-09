require 'spec_helper'

describe Admin::RequestsController do
  before :each do
    login(Factory.create(:sysadmin))
  end

  it "cannot can delete data_request without data_responses" do
    data_request = Factory.create(:data_request)

    delete :destroy, :id => data_request.id
    flash[:notice].should == "Request was successfully deleted."
    response.should redirect_to(admin_requests_url)
  end

  it "cannot delete data_request that has data_responses" do
    data_request = Factory.create(:data_request)
    data_response = Factory.create(:data_response, :data_request => data_request)

    delete :destroy, :id => data_request.id
    flash[:error].should == "You cannot delete request that has responses."
    response.should redirect_to(admin_requests_url)
  end
end
