require File.dirname(__FILE__) + '/../../spec_helper'

describe Activity, "GOR Quarters" do
  describe "USG Fiscal Year" do
    before :each do
      @organization = Factory(:organization,
                              :fiscal_year_start_date => "2010-10-01",
                              :fiscal_year_end_date => "2011-09-30")
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
      @activity.gor_budget_quarter(1).should == 11
      @activity.gor_budget_quarter(2).should == 22
      @activity.gor_budget_quarter(3).should == 33
      @activity.gor_budget_quarter(4).should == 44
      @activity.gor_spend_quarter(1).should == 111
      @activity.gor_spend_quarter(2).should == 222
      @activity.gor_spend_quarter(3).should == 333
      @activity.gor_spend_quarter(4).should == 444
      lambda { @activity.gor_budget_quarter(0)
               }.should raise_error(Activity::GorAmountHelpers::InvalidQuarter)
      lambda { @activity.gor_budget_quarter(5)
               }.should raise_error(Activity::GorAmountHelpers::InvalidQuarter)
      lambda { @activity.gor_spend_quarter(0)
               }.should raise_error(Activity::GorAmountHelpers::InvalidQuarter)
      lambda { @activity.gor_spend_quarter(5)
               }.should raise_error(Activity::GorAmountHelpers::InvalidQuarter)
    end
  end

  describe "GOR Fiscal Year" do
    before :each do
      @organization = Factory(:organization,
                              :fiscal_year_start_date => "2010-07-01",
                              :fiscal_year_end_date => "2011-06-30")
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
      @activity.gor_budget_quarter(1).should == 22
      @activity.gor_budget_quarter(2).should == 33
      @activity.gor_budget_quarter(3).should == 44
      @activity.gor_budget_quarter(4).should == 55
      @activity.gor_spend_quarter(1).should == 222
      @activity.gor_spend_quarter(2).should == 333
      @activity.gor_spend_quarter(3).should == 444
      @activity.gor_spend_quarter(4).should == 555
      lambda { @activity.gor_budget_quarter(0)
               }.should raise_error(Activity::GorAmountHelpers::InvalidQuarter)
      lambda { @activity.gor_budget_quarter(5)
               }.should raise_error(Activity::GorAmountHelpers::InvalidQuarter)
      lambda { @activity.gor_spend_quarter(0)
               }.should raise_error(Activity::GorAmountHelpers::InvalidQuarter)
      lambda { @activity.gor_spend_quarter(5)
               }.should raise_error(Activity::GorAmountHelpers::InvalidQuarter)
    end
  end
end
