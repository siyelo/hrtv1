require 'spec_helper'

describe Reports::CountriesController do

  before :each do
    @admin = Factory.create(:admin, :current_response => Factory(:data_response))
    login @admin
    @location = Factory.create(:location)
  end

  describe "GET 'show'" do
    it "should be successful" do
      Reports::ActivityReport.stub!(:top_by_spent).and_return {}
      Reports::OrganizationReport.stub!(:top_by_spent).and_return {}
      get :show
      response.should be_success
       response.flash.now[:warning].should =~ /^You are now viewing data for the Request:.*/
    end
  end
end
