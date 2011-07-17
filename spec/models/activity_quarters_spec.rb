require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  describe "US Goverment" do
    before :all do
      @organization = Factory(:organization,
                              :fiscal_year_start_date => Date.parse("2010-10-01"),
                              :fiscal_year_end_date => Date.parse("2011-09-30"))
      @request      = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
      @project      = Factory(:project, :data_response => @response)
      @activity     = Factory(:activity, :data_response => @response, :project => @project,
                              :budget_q4_prev => 11, :budget_q1 => 22,
                              :budget_q2 => 33, :budget_q3 => 44, :budget_q4 => 55,
                              :spend_q4_prev => 111, :spend_q1 => 222,
                              :spend_q2 => 333, :spend_q3 => 444, :spend_q4 => 555)
    end

    it "returns proper budget and spend for all quarters" do
      @activity.budget_quarter(1).should == 11
      @activity.budget_quarter(2).should == 22
      @activity.budget_quarter(3).should == 33
      @activity.budget_quarter(4).should == 44
      @activity.spend_quarter(1).should == 111
      @activity.spend_quarter(2).should == 222
      @activity.spend_quarter(3).should == 333
      @activity.spend_quarter(4).should == 444
      lambda { @activity.budget_quarter(0)
               }.should raise_error(BudgetSpendHelpers::InvalidQuarter)
      lambda { @activity.budget_quarter(5)
               }.should raise_error(BudgetSpendHelpers::InvalidQuarter)
      lambda { @activity.spend_quarter(0)
               }.should raise_error(BudgetSpendHelpers::InvalidQuarter)
      lambda { @activity.spend_quarter(5)
               }.should raise_error(BudgetSpendHelpers::InvalidQuarter)
    end
  end

  describe "US Goverment" do
    before :all do
      @organization = Factory(:organization,
                              :fiscal_year_start_date => Date.parse("2010-01-01"),
                              :fiscal_year_end_date => Date.parse("2010-12-31"))
      @request      = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
      @project      = Factory(:project, :data_response => @response)
      @activity     = Factory(:activity, :data_response => @response, :project => @project,
                              :budget_q4_prev => 11, :budget_q1 => 22,
                              :budget_q2 => 33, :budget_q3 => 44, :budget_q4 => 55,
                              :spend_q4_prev => 111, :spend_q1 => 222,
                              :spend_q2 => 333, :spend_q3 => 444, :spend_q4 => 555)
    end

    it "returns proper budget and spend for all quarters" do
      @activity.budget_quarter(1).should == 22
      @activity.budget_quarter(2).should == 33
      @activity.budget_quarter(3).should == 44
      @activity.budget_quarter(4).should == 55
      @activity.spend_quarter(1).should == 222
      @activity.spend_quarter(2).should == 333
      @activity.spend_quarter(3).should == 444
      @activity.spend_quarter(4).should == 555
      lambda { @activity.budget_quarter(0)
               }.should raise_error(BudgetSpendHelpers::InvalidQuarter)
      lambda { @activity.budget_quarter(5)
               }.should raise_error(BudgetSpendHelpers::InvalidQuarter)
      lambda { @activity.spend_quarter(0)
               }.should raise_error(BudgetSpendHelpers::InvalidQuarter)
      lambda { @activity.spend_quarter(5)
               }.should raise_error(BudgetSpendHelpers::InvalidQuarter)
    end
  end
end
