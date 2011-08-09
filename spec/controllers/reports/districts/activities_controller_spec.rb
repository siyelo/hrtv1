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
    @activity = Factory(:activity, :data_response => @data_response, :project => @project)
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

  describe "access" do
    context "district_manager" do
      before :each do
        @location1 = Factory(:location)
        @district_manager = Factory(:district_manager, :location => @location1)
        login @district_manager
      end

      context "index" do
        it "is able to access activities index page for the managed district" do
          get :index, :district_id => @location1.id
          response.should render_template(:index)
        end

        it "is not able to access activities index page for other district" do
          @location2 = Factory(:location)
          get :index, :district_id => @location2.id
          response.should redirect_to(login_path)
        end
      end

      context "show" do
        it "is able to access activities index page for the managed district" do
          get :show, :id => @activity.id, :district_id => @location1.id
          response.should render_template(:show)
        end

        it "is not able to access activities index page for other district" do
          @location2 = Factory(:location)
          get :show, :id => @activity.id, :district_id => @location2.id
          response.should redirect_to(login_path)
        end
      end
    end
  end
end
