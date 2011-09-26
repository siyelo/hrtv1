require File.dirname(__FILE__) + '/../../spec_helper'

describe Activity, "Currency" do
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
      project       = Factory(:project, :data_response => @dr)
      @a            = Factory(:activity, :data_response => @dr,
                              :project => project)
      @split = Factory :implementer_split, :activity => @a,
        :spend => 123.45, :budget => 123.45, :organization => @organization
      @organization.reload # needs reload for dr_activities association to work
      @a.reload
      @a.save
    end

    it "should update spend in USD on creation" do
      @a.spend_in_usd.to_f.should == 123.45
    end

    it "should update spend in USD on update" do
      @split.spend = 456.78; @split.save
      @a.reload; @a.save # re-cache
      @a.spend_in_usd.to_f.should == 456.78
    end

    it "should update spend in USD after project currency change" do
      @p = @a.project
      @p.currency = 'RWF'
      @p.save
      @a.reload
      @a.save # re-cache
      @a.spend_in_usd.to_f.should == 0.2469
    end

    it "should update spend in USD after organization currency change" do
      @organization.currency = "RWF"
      @organization.save
      @organization.currency.should == "RWF"
      @a.reload
      @a.spend_in_usd.to_f.should == 0.2469
    end

    it "should update spend in USD after currency change with a big number" do
      @p = @a.project
      @p.currency = 'RWF'
      @p.save
      @split.spend = 7893.10; @split.save
      @a.reload; @a.save
      @a.spend_in_usd.to_f.should == 15.7862
    end

    it "should update new_budget on creation" do
      @a.budget_in_usd.to_f.should == 123.45
    end

    it "should update budget in USD on update" do
      @split.budget = 456.79; @split.save
      @a.reload; @a.save
      @a.budget_in_usd.to_f.should == 456.79
    end

    it "should update budget in USD after currency change" do
      @p = @a.project
      @p.currency = 'RWF'
      @p.save
      @split.budget = 789.10; @split.save
      @a.reload; @a.save
      @a.budget_in_usd.to_f.should ==  789.10 * 0.002
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

    it "should return the organization's currency, unless the project overrides it" do
      @a.currency.should == "RWF"

      p = @a.project
      p.currency = 'CHF'
      p.save

      @a.reload
      @a.currency.should == "CHF"
    end
  end
end
