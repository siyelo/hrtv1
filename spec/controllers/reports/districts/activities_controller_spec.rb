require 'spec_helper'

describe Reports::Districts::ActivitiesController do

  before :each do
    @data_request = Factory(:data_request)
    @data_response = Factory(:data_response, :data_request => @data_request)
    @admin = Factory.create(:admin)
    @admin.data_response_id_current = @data_response.id
    @admin.save
    login @admin
    @location = Factory.create(:location)
    @activity = Factory.create(:activity, :data_response => @data_response, :locations => [@location])
  end

  describe "GET 'index'" do
    it "should be successful" do
      Location.should_receive(:find).with(@location.id.to_s).and_return(@location)
      Reports::ActivityReport.should_receive(:top_by_spent_and_budget).and_return([@activity])
      get 'index', :district_id => @location.id, :request_id => @data_request.id
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "should be successful" do
      Location.should_receive(:find).with(@location.id.to_s).and_return(@location)
      Activity.should_receive(:find).with(@activity.id.to_s).and_return(@activity)
      get :show, :id => @activity.id, :district_id => @location.id
      response.should be_success
    end
  end
end
