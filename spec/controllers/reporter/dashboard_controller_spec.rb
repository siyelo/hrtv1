require 'spec_helper'

describe Reporter::DashboardController do

  before :each do
    @reporter = Factory.create(:reporter) # side effect - creates a response/request
    @data_request = Factory(:data_request) # a newer request, so we get a flash
    login @reporter
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
      response.flash.now[:warning].should =~ /^You are now viewing data for the Request:.*/
    end
  end
end
