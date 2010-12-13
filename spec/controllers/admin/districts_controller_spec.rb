require 'spec_helper'

describe Admin::DistrictsController do

  before :each do
    @admin = Factory.create(:admin)
    login @admin
    Location.stub!(:find).with("1").and_return(@mock_object = mock_model(Location))
  end

  describe "GET 'index'" do
    it "should be successful" do
      Location.should_receive(:all).and_return([@mock_object])
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "should be successful" do
      Location.should_receive(:find).with("1").and_return(@mock_object)
      get :show, :id => "1"
      response.should be_success
    end
  end
end
