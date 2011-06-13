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
      @organization = Factory.create(:organization)
      @reporter = Factory.create(:reporter, :organization => @organization)
      login @reporter
      ## Note: @response (and @request?) reserved by rspec
      @data_request = Factory(:data_request)
      @data_response = Factory.create(:data_response,
                                      :data_request => @data_request,
                                      :organization => @organization)
    end

    it "GET/1/implementers should find all activities" do
      #DataResponse.should_receive(:find).and_return(@data_response)
      get :index, :response_id => @data_response.id
      response.should be_success
    end
  end
end
