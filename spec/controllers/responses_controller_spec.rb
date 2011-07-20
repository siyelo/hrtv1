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
end
