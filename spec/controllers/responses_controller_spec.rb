require 'spec_helper'

describe ResponsesController do
  describe "Routing shortcuts should map" do
    it "GET (review) with /responses/1/review" do
      params_from(:get, '/responses/1/review').should == {:controller => "responses",
        :id => "1", :action => "review"}
    end
    it "GET (submit) with /responses/1/submit" do
      params_from(:get, '/responses/1/submit').should == {:controller => "responses",
        :id => "1", :action => "submit"}
    end
    it "PUT (send_data_response) with /responses/1/send_data_response" do
      params_from(:put, '/responses/1/send_data_response').should == {:controller => "responses",
        :id => "1", :action => "send_data_response"}
    end
  end

  #TODO: spec review
  #TODO: spec submit
  #TODO: spec send_data_response
  describe "Requesting Responses endpoints as a reporter" do
    before :each do
      @organization  = Factory(:organization)
      @data_request  = Factory(:data_request, :organization => @organization)
      @data_response = @organization.latest_response
      @reporter      = Factory(:reporter, :organization => @organization)
      login @reporter
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
      it { should redirect_to(response_workplans_path(DataResponse.last)) }
    end
  end
end
