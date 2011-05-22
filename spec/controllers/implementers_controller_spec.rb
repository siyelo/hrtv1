require 'spec_helper'

describe ImplementersController do
  describe "Routing shortcuts should map" do
    it "GET (edit) with /responses/1/implementers/spend/edit" do
      params_from(:get, '/responses/1/implementers/spend/edit').should == {
        :controller => "implementers",
        :action => "edit",
        :response_id => '1',
        :id => "spend"}
    end
  end

  describe "Requesting Implementers endpoints as a reporter" do
    before :each do
      @reporter = Factory.create(:reporter)
      login @reporter
      ## Note: @response (and @request?) reserved by rspec
      @data_request = Factory(:data_request)
      @data_response = Factory.create(:data_response, :data_request => @data_request)
    end

    it "GET/1/implementers/edit should find all activities" do
      DataResponse.should_receive(:find).and_return(@data_response)
      get :edit, :response_id => 1, :id => :spend
      response.should be_success
    end
  end
end
