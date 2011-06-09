require 'spec_helper'

describe Admin::ResponsesController do
  describe "Routing shortcuts should map" do
    it "GET (index) with /admin/responses" do
      params_from(:get, '/admin/responses').should == {:controller => "admin/responses", :action => "index"}
    end
    it "GET (show) with /admin/responses/1" do
      params_from(:get, '/admin/responses/1').should == {:controller => "admin/responses", :id => "1", :action => "show"}
    end
    it "DELETE with /admin/responses/1" do
      params_from(:delete, "/admin/responses/1").should == {:controller => "admin/responses", :id => "1", :action => "destroy"}
    end
  end
  
  describe "Requesting Admin::Responses endpoints as a sysadmin" do
    before :each do
      @admin = Factory.create(:admin)
      login @admin
      @data_response = Factory.create(:data_response)
    end
      
    it "/index should find the submitted responses" do
      get :index
      response.should be_success
    end
    
    it "/submitted should find the submitted responses" do
      get :submitted
      response.should be_success
    end

    it "/in_progress should find the in_progress responses" do
      get :in_progress
      response.should be_success
    end 
    
    it "/empty should find the empty responses" do
      get :empty
      response.should be_success
    end
  
    it "GET/1 should find a response" do
      (@codes = [Factory(:code)])
      Code.stub_chain(:purposes, :roots).and_return(@codes)
      DataResponse.should_receive(:find).with('1').and_return(@data_response)
      Code.should_receive(:purposes)
      CostCategory.should_receive(:roots)
      OtherCostCode.should_receive(:roots)
      get :show, :id => 1
      response.should be_success
    end
  end
end
