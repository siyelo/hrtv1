require 'spec_helper'

describe Admin::Districts::ActivitiesController do
  
  before :each do
    @admin = Factory.create(:admin)
    login @admin
    @location = Factory.create(:location)
    @activity = Factory.create(:activity, :locations => [@location])
  end

  describe "GET 'index'" do
    it "should be successful" do
      Location.should_receive(:find).with("1").and_return(@location)
      Activity.should_receive(:all).and_return([@activity])
      get 'index', :district_id => @location.id
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "should be successful" do
      Location.should_receive(:find).with("1").and_return(@location)
      Activity.should_receive(:find).with("1").and_return(@activity)
      get :show, :id => "1", :district_id => @location.id
      response.should be_success
    end
  end
end
