require 'spec_helper'

describe Reports::Districts::ActivitiesController do

  before :each do
    @organization  = Factory(:organization)
    @data_request  = Factory(:data_request, :organization => @organization)
    @data_response = @organization.latest_response
    @project       = Factory(:project, :data_response => @data_response)
    @admin         = Factory(:admin, :organization => @organization)
    login @admin
    @location = Factory(:location)
    @activity = Factory(:activity, :data_response => @data_response,
                        :project => @project, :locations => [@location])
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
