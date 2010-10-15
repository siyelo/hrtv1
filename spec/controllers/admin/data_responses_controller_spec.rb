require 'spec_helper'

describe Admin::DataResponsesController do
  describe "Routing shortcuts should map" do
    it "GET (index) with /admin/data_responses" do
      params_from(:get, '/admin/data_responses').should == {:controller => "admin/data_responses", :action => "index"}
    end
    it "GET (show) with /admin/data_responses/1" do
      params_from(:get, '/admin/data_responses/1').should == {:controller => "admin/data_responses", :id => "1", :action => "show"}
    end
    it "DELETE with /admin/data_responses/1" do
      params_from(:delete, "/admin/data_responses/1").should == {:controller => "admin/data_responses", :id => "1", :action => "destroy"}
    end
  end
  
  describe "Requesting Admin::DataResponses endpoints as an admin" do
    before :each do
      @admin = Factory.create(:admin)
      login @admin
      @data_response = Factory.create(:data_response)
      @data_responses.stub!(:find).and_return(@data_response)
    end
    context "Requesting /admin/data_responses using GET" do
      it "should find the data_responses" do
        pending
        DataResponse.should_receive(:find).with(:all).and_return(@data_response)
        get :index
      end
    end
    context "Requesting /admin/data_responses/1 using GET" do
      it "should find the data_responses" do
        DataResponse.should_receive(:find).with('1').and_return(@data_response)
        get :show, :id => 1
      end
    end
    
  end
  
end
