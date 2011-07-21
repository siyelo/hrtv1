require 'spec_helper'

describe Admin::CurrenciesController do
  describe "Routing shortcuts should map" do
    it "GET (index) with /admin/currencies" do
      params_from(:get, '/admin/currencies').should == {:controller => "admin/currencies", :action => "index"}
    end
    it "GET (update) with /admin/currencies/1" do
      params_from(:put, '/admin/currencies/1').should == {:controller => "admin/currencies", :id => "1", :action => "update"}
    end
    it "DELETE with /admin/currencies/1" do
      params_from(:delete, "/admin/currencies/1").should == {:controller => "admin/currencies", :id => "1", :action => "destroy"}
    end
  end
  
  describe "Updating the currency" do
    it "updates the default bank when the currency is updated" do
      pending
      post :create, :currency => {:from => "UZS", :to => "VEF", :rate => 99}
      Money.default_bank.get_rate("UZS", "VEF").should == 99.0
    end
  end
end