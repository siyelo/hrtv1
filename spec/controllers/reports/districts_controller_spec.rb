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

  describe "access" do
    context "district_manager" do
      before :each do
        @location1 = Factory(:location)
        @district_manager = Factory(:district_manager, :location => @location1)
        login @district_manager
      end

      it "is not able to access districts index page" do
        get :index
        response.should redirect_to(login_path)
      end

      it "is not able to access district show page for other district" do
        @location2 = Factory(:location)
        get :show, :id => @location2.id
        response.should redirect_to(login_path)
      end

      it "is be able to access district show page for the managed district" do
        get :show, :id => @location1.id
        response.should render_template(:show)
      end
    end
  end
end
