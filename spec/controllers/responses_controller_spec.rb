require 'spec_helper'

describe ResponsesController do
  describe "Routing shortcuts should map" do
    it "GET (new) with /responses/new" do
      params_from(:get, '/responses/new').should == {:controller => "responses",
        :action => "new"}
    end
    it "POST (create) with /responses/new" do
      params_from(:post, '/responses/').should == {:controller => "responses",
        :action => "create"}
    end
    it "GET (show) with /responses/1" do
      params_from(:get, '/responses/1').should == {:controller => "responses",
        :id => "1", :action => "show"}
    end
    it "DELETE with /responses/1" do
      params_from(:delete, "/responses/1").should == {:controller => "responses",
        :id => "1", :action => "destroy"}
    end
  end

  describe "Requesting Responses endpoints as a reporter" do
    before :each do
      @reporter = Factory.create(:reporter)
      login @reporter
      ## Note: @response (and @request?) reserved by rspec
      @data_request = Factory(:data_request)
      @data_response = Factory.create(:data_response, :data_request => @data_request)
    end

    context "create new response" do
      before :each do
        post :create, :data_response => {:data_request_id => @data_request.id,
          :fiscal_year_start_date => "2011-05-01",
          :fiscal_year_end_date => "2011-05-31",
          :currency => "RWF",
          :contact_name => "cname",
          :contact_office_location => "loc",
          :contact_phone_number => "0123455",
          :contact_main_office_phone_number => "0123123",
          :contact_position => "director"
          }
      end
      it { should redirect_to(edit_response_workplan_path(DataResponse.last, :spend)) }
    end
  end
end
