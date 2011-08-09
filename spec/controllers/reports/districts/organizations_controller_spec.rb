require 'spec_helper'

describe Reports::Districts::OrganizationsController do
  describe "access" do
    before :each do
      @organization  = Factory(:organization)
      @data_request  = Factory(:data_request, :organization => @organization)
    end

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
          get :show, :id => @organization.id, :district_id => @location1.id
          response.should render_template(:show)
        end

        it "is not able to access activities index page for other district" do
          @location2 = Factory(:location)
          get :show, :id => @organization.id, :district_id => @location2.id
          response.should redirect_to(login_path)
        end
      end
    end
  end
end
