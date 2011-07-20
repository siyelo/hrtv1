require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  describe "currency" do
    it "complains when you dont have a project (therefore currency)" do
      lambda { activity = Factory(:activity, :projects => []) }.should raise_error
    end

    it "returns project currency when activity has currency" do
      basic_setup_response
      @project = Factory(:project, :data_response => @response, :currency => 'USD')
      activity = Factory(:activity, :data_response => @response, :project => @project)
      activity.currency.should == "USD"
    end
  end

  describe "keeping Money amounts in-sync" do
    before :each do
      Money.default_bank.add_rate(:RWF, :USD, 0.002)
      @organization = Factory(:organization, :currency => 'USD')
      @data_request = Factory(:data_request, :organization => @organization)
      @dr           = @organization.latest_response
      @a            = Factory(:activity, :data_response => @dr,
                              :project => Factory(:project, :data_response => @dr))
      @a.budget = 123.45
      @a.spend  = 123.45
      @a.save
      @a.reload
    end

    it "should update spend in USD on creation" do
      @a.spend_in_usd.should == 123.45
    end

    it "should update spend in USD on update" do
      @a.spend = 456.78
      @a.save
      @a.spend_in_usd.should == 456.78
    end

    it "should update spend_in_USD after currency change" do
      @p = @a.project
      @p.currency = 'RWF'
      @p.save
      @a.reload
      @a.spend = 789.10
      @a.save
      @a.spend_in_usd.should == 1.5782
    end

    it "should update spend_in_USD after currency change with a big number" do
      @p = @a.project
      @p.currency = 'RWF'
      @p.save
      @a.reload
      @a.spend = 7893.10
      @a.save
      @a.spend_in_usd.should == 15.7862
    end

    it "should update new_budget on creation" do
      @a.budget_in_usd.should == 123.45
    end

    it "should update budget_in_usd on update" do
      @a.budget = 456.79
      @a.save
      @a.budget_in_usd.should == 456.79
    end

    it "should update budget_in_usd after currency change" do
      @p = @a.project
      @p.currency = 'RWF'
      @p.save
      @a.reload
      @a.budget = 789.10
      @a.save
      @a.budget_in_usd.should ==  789.10 * 0.002
    end
  end

  describe "currency convenience lookups on DR/Project" do
    before :each do
      @organization = Factory(:organization, :currency => 'RWF')
      @data_request = Factory(:data_request, :organization => @organization)
      @dr           = @organization.latest_response
      @project      = Factory(:project, :data_response => @dr)
      @a            = Factory(:activity, :data_response => @dr, :project => @project)
    end

    it "should return the data response's currency" do
      @a.currency.should == "RWF"
    end

    it "should return the data response's currency, unless the project overrides it" do
      p = @a.project
      p.currency = 'CHF'
      p.save
      @a.reload
      @a.currency.should == "CHF"
    end
  end
end
