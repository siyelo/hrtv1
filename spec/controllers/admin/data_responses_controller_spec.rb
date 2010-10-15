require 'spec_helper'

describe Admin::DataResponsesController do
  describe "Routing shortcuts should map" do
    it "GET with /admin/data_responses" do
      params_from(:get, '/admin/data_responses').should == {:controller => "admin/data_responses", :action => "index"}
    end
    it "DELETE with /admin/data_responses/1" do
      params_from(:delete, "/admin/data_responses/1").should == {:controller => "admin/data_responses", :id => "1", :action => "destroy"}
    end
  end
end
