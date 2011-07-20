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
      Money.default_bank.get_rate("MEH", "BLEH").should raise_error(Money::Currency::UnknownCurrency)
      post :create, :from => "MEH", :to => "BLEH", :rate => 99
      Money.default_bank.get_rate("MEH", "BLEH").should == 99.0
    end
  end
end