require 'spec_helper'

describe Admin::RequestsController do
  before :each do
    login(Factory.create(:sysadmin))
  end

  it "can delete data_request" do
    data_request = Factory.create(:data_request)
    delete :destroy, :id => data_request.id
    flash[:notice].should == "Request was successfully deleted."
    response.should redirect_to(admin_requests_url)
  end
end
