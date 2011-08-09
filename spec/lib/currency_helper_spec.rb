require File.dirname(__FILE__) + '/../spec_helper'

class Foo
  include CurrencyHelper
end

describe CurrencyHelper do
  before :each do
    Money.default_bank.set_rate(:RWF, :USD, 1)
    Money.default_bank.set_rate(:USD, :USD, 1)
    Money.default_bank.set_rate(:EUR, :USD, 1)
    Money.default_bank.set_rate(:CHF, :USD, 1)
    @foo = Foo.new
  end

  it "should return the currency for select" do
    @foo.currency_options_for_select.should include(["Euro (EUR)", "EUR"])
  end

  describe "major currencies" do
    it "should return major currencies" do
      if ENV['HRT_COUNTRY'] == 'kenya'
        @foo.major_currencies(Money::Currency::TABLE).should == [:kes, :usd, :eur, :chf]
      else
        @foo.major_currencies(Money::Currency::TABLE).should == [:rwf, :usd, :eur, :chf]
      end
    end

    it "should appear in the currency for select only once" do
      @foo.currency_options_for_select.should include(["Euro (EUR)", "EUR"])
      @foo.currency_options_for_select.count(["Euro (EUR)", "EUR"]).should == 1
    end
  end

  describe "no _to_usd exchange rate" do
    it "should not return a major currency" do
      Money.default_bank.set_rate(:CHF, :USD, nil)
      if ENV['HRT_COUNTRY'] == 'kenya'
        @foo.major_currencies(Money::Currency::TABLE).should == [:kes, :usd, :eur]
      else
        @foo.major_currencies(Money::Currency::TABLE).should == [:rwf, :usd, :eur]
      end
    end

    it "should exclude USD if its not specfied (edge case)" do
      Money.default_bank.set_rate(:USD, :USD, nil)
      if ENV['HRT_COUNTRY'] == 'kenya'
        @foo.major_currencies(Money::Currency::TABLE).should == [:kes, :eur, :chf]
      else
        @foo.major_currencies(Money::Currency::TABLE).should == [:rwf, :eur, :chf]
      end
    end

    it "should not return a currency for select" do
      Money.default_bank.set_rate(:BZD, :USD, nil)
      @foo.currency_options_for_select.should_not include(["Belize Dollar (BZD)", "BZD"])
    end
  end
end
