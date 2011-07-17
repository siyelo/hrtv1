require 'spec_helper'

describe Reports::CountriesController do

  before :each do
    @organization  = Factory(:organization)
    @data_request  = Factory(:data_request, :organization => @organization)
    @data_response = @organization.latest_response
    @admin = Factory.create(:admin, :organization => @organization)
    login @admin
    @location = Factory.create(:location)
  end

  describe "GET 'show'" do
    it "should be successful" do
      # create another request to get the flash warning
      @data_request  = Factory(:data_request, :organization => @organization)
      Reports::ActivityReport.stub!(:top_by_spent).and_return {}
      Reports::OrganizationReport.stub!(:top_by_spent).and_return {}
      get :show
      response.should be_success
       response.flash.now[:warning].should =~ /^You are now viewing data for the Request:.*/
    end
  end
end
