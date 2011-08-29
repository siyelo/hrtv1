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

  describe "Creating a currency" do
    it "creates the currency properly despite it being created with lowercase" do
      post :create, :currency => {:from => "bwp", :rate => 1.6, :to =>"zar"}
      Money.default_bank.get_rate("BWP", "ZAR").should == 1.6
    end
    it "does not create the currency if the same conversion exists" do
      post :create, :currency => {:from => "USD", :rate => 9.6, :to =>"EUR"}
      Currency.find_by_conversion('USD_TO_EUR').rate.should_not == 9.6
      flash[:error].should == "Conversion has already been taken"
      response.should redirect_to admin_currencies_path
    end
  end

  describe "Updating the currency" do
    after :all do
      @currency = Currency.find_by_conversion('USD_TO_USD')
      @currency.rate = 1; @currency.save ## because the currency rates are persisted in the database
      @currency = Currency.find_by_conversion('RWF_TO_USD')
    end

    it "updates the default bank when the currency is updated" do
      @currency = Currency.find_by_conversion('USD_TO_USD')
      put :update, :id => @currency.id, :rate => 98
      @currency.reload
      Money.default_bank.get_rate("USD", "USD").should == 98.0
    end
  end
end
