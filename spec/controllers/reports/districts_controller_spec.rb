require 'spec_helper'

describe Reports::DistrictsController do
  before :each do
    @organization  = Factory(:organization)
    @data_request  = Factory(:data_request, :organization => @organization)
    @data_response = @organization.latest_response
    @admin = Factory.create(:admin, :organization => @organization)
    login @admin
    @location = Factory.create(:location)
  end

  describe "GET 'index'" do
    it "should be successful" do
      # create another request to get the flash warning
      @data_request  = Factory(:data_request, :organization => @organization)
      Location.should_receive(:all_with_counters).and_return([@location])
      get 'index'
      response.should be_success
      response.flash.now[:warning].should =~ /^You are now viewing data for the Request:.*/
    end
  end

  describe "GET 'show'" do
    it "should be successful" do
      Location.should_receive(:find).with("1").and_return(@location)
      get :show, :id => "1"
      response.should be_success
    end
  end
end
