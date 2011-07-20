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
      @admin = Factory.create(:sysadmin)
      login @admin
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
      organization = Factory(:organization)
      data_request = Factory(:data_request)
      reporter = Factory(:reporter, :organization => organization)
      get :show, :id => reporter.current_response.id
      response.should be_success
    end
  end
end
