require 'spec_helper'

describe ResponsesController do
  describe "Routing shortcuts should map" do
    it "GET (review) with /responses/1/review" do
      params_from(:get, '/responses/1/review').should == {:controller => "responses",
        :id => "1", :action => "review"}
    end

    it "PUT (submit) with /responses/1/submit" do
      params_from(:put, '/responses/1/submit').should == {:controller => "responses",
        :id => "1", :action => "submit"}
    end
  end
end
