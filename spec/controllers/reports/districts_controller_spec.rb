require 'spec_helper'

describe Reports::DistrictsController do

  before :each do
    @admin = Factory.create(:admin, :current_response => Factory(:data_response))
    login @admin
    @location = Factory.create(:location)
  end

  describe "GET 'index'" do
    it "should be successful" do
      Location.should_receive(:all_with_counters).and_return([@location])
      get 'index'
      response.should be_success
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
