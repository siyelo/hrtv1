require File.dirname(__FILE__) + '/../../spec_helper'

describe Activity, "GOR Quarters" do

  def setup_activity_in_fiscal_year(fy_start, fy_end, attributes)
    @organization = Factory(:organization,
                            :fiscal_year_start_date => fy_start,
                            :fiscal_year_end_date => fy_end)
    @request      = Factory(:data_request, :organization => @organization)
    @response     = @organization.latest_response
    @project      = Factory(:project, :data_response => @response)
    @activity     = Factory(:activity, {:data_response => @response,
                                        :project => @project}.merge(attributes))
  end

  describe "#gor_budget_quarter" do
    context "USG Fiscal Year" do
      it "returns proper budget and spend for all quarters" do
        attributes = {:budget_q4_prev => 11, :budget_q1 => 22,
                      :budget_q2 => 33, :budget_q3 => 44, :budget_q4 => 55}
        setup_activity_in_fiscal_year("2010-10-01", "2011-09-30", attributes)
        @activity.gor_budget_quarter(1).should == 11
        @activity.gor_budget_quarter(2).should == 22
        @activity.gor_budget_quarter(3).should == 33
        @activity.gor_budget_quarter(4).should == 44
        lambda { @activity.gor_budget_quarter(0)
                 }.should raise_error(Activity::GorAmountHelpers::InvalidQuarter)
        lambda { @activity.gor_budget_quarter(5)
                 }.should raise_error(Activity::GorAmountHelpers::InvalidQuarter)
      end
    end

    context "GOR Fiscal Year" do
      it "returns proper budget and spend for all quarters" do
        attributes = {:budget_q4_prev => 11, :budget_q1 => 22,
                      :budget_q2 => 33, :budget_q3 => 44, :budget_q4 => 55}
        setup_activity_in_fiscal_year("2010-07-01", "2011-06-30", attributes)
        @activity.gor_budget_quarter(1).should == 22
        @activity.gor_budget_quarter(2).should == 33
        @activity.gor_budget_quarter(3).should == 44
        @activity.gor_budget_quarter(4).should == 55
        lambda { @activity.gor_budget_quarter(0)
                 }.should raise_error(Activity::GorAmountHelpers::InvalidQuarter)
        lambda { @activity.gor_budget_quarter(5)
                 }.should raise_error(Activity::GorAmountHelpers::InvalidQuarter)
      end
    end
  end

  describe "#gor_spend_quarter" do
    context "USG Fiscal Year" do
      it "returns proper budget and spend for all quarters" do
        attributes = {:spend_q4_prev => 111, :spend_q1 => 222,
                      :spend_q2 => 333, :spend_q3 => 444, :spend_q4 => 555}
        setup_activity_in_fiscal_year("2010-10-01", "2011-09-30", attributes)
        @activity.gor_spend_quarter(1).should == 111
        @activity.gor_spend_quarter(2).should == 222
        @activity.gor_spend_quarter(3).should == 333
        @activity.gor_spend_quarter(4).should == 444
        lambda { @activity.gor_spend_quarter(0)
                 }.should raise_error(Activity::GorAmountHelpers::InvalidQuarter)
        lambda { @activity.gor_spend_quarter(5)
                 }.should raise_error(Activity::GorAmountHelpers::InvalidQuarter)
      end
    end

    context "GOR Fiscal Year" do
      it "returns proper budget and spend for all quarters" do
        attributes = {:spend_q4_prev => 111, :spend_q1 => 222,
                      :spend_q2 => 333, :spend_q3 => 444, :spend_q4 => 555}
        setup_activity_in_fiscal_year("2010-07-01", "2011-06-30", attributes)
        @activity.gor_spend_quarter(1).should == 222
        @activity.gor_spend_quarter(2).should == 333
        @activity.gor_spend_quarter(3).should == 444
        @activity.gor_spend_quarter(4).should == 555
        lambda { @activity.gor_spend_quarter(0)
                 }.should raise_error(Activity::GorAmountHelpers::InvalidQuarter)
        lambda { @activity.gor_spend_quarter(5)
                 }.should raise_error(Activity::GorAmountHelpers::InvalidQuarter)
      end
    end
  end

  describe "#gor_budget" do
    context "USG Fiscal Year" do
      context "quarter values are present" do
        it "returns sum of q4_prev, q1, q2 and q3" do
          attributes = {:budget_q4_prev => 11, :budget_q1 => 22,
                        :budget_q2 => 33, :budget_q3 => 44, :budget_q4 => 55}
          setup_activity_in_fiscal_year("2010-10-01", "2011-09-30", attributes)
          @activity.gor_budget.should == 110
        end
      end

      context "all amounts are nil" do
        it "returns nil" do
          attributes = {:budget_q4_prev => nil, :budget_q1 => nil,
                        :budget => nil, :budget_q2 => nil, :budget_q3 => nil, :budget_q4 => nil}
          setup_activity_in_fiscal_year("2010-10-01", "2011-09-30", attributes)
          @activity.gor_budget.should == 0
        end
      end
    end

    context "GOR Fiscal Year" do
      context "quarterly amounts are present" do
        it "returns sum of q4_prev, q1, q2 and q3" do
          attributes = {:budget_q4_prev => 11, :budget_q1 => 22,
                        :budget_q2 => 33, :budget_q3 => 44, :budget_q4 => 55}
          setup_activity_in_fiscal_year("2010-07-01", "2011-06-30", attributes)
          @activity.gor_budget.should == 154
        end
      end

      context "all amounts are nil" do
        it "returns 0" do
          attributes = {:budget_q4_prev => nil, :budget_q1 => nil,
                        :budget => nil, :budget_q2 => nil, :budget_q3 => nil, :budget_q4 => nil}
          setup_activity_in_fiscal_year("2010-07-01", "2011-06-30", attributes)
          @activity.gor_budget.should == 0
        end
      end
    end
  end

  describe "#gor_spend" do
    context "USG Fiscal Year" do
      context "quarter values are present" do
        it "returns sum of q4_prev, q1, q2 and q3" do
          attributes = {:spend_q4_prev => 11, :spend_q1 => 22,
                        :spend_q2 => 33, :spend_q3 => 44, :spend_q4 => 55}
          setup_activity_in_fiscal_year("2010-10-01", "2011-09-30", attributes)
          @activity.gor_spend.should == 110
        end
      end

      context "all amounts are nil" do
        it "returns nil" do
          attributes = {:spend_q4_prev => nil, :spend_q1 => nil,
                        :spend => nil, :spend_q2 => nil, :spend_q3 => nil, :spend_q4 => nil}
          setup_activity_in_fiscal_year("2010-10-01", "2011-09-30", attributes)
          @activity.gor_spend.should == 0
        end
      end
    end

    context "GOR Fiscal Year" do
      context "quarterly amounts are present" do
        it "returns sum of q4_prev, q1, q2 and q3" do
          attributes = {:spend_q4_prev => 11, :spend_q1 => 22,
                        :spend_q2 => 33, :spend_q3 => 44, :spend_q4 => 55}
          setup_activity_in_fiscal_year("2010-07-01", "2011-06-30", attributes)
          @activity.gor_spend.should == 154
        end
      end

      context "all amounts are nil" do
        it "returns 0" do
          attributes = {:spend_q4_prev => nil, :spend_q1 => nil,
                        :spend => nil, :spend_q2 => nil, :spend_q3 => nil, :spend_q4 => nil}
          setup_activity_in_fiscal_year("2010-07-01", "2011-06-30", attributes)
          @activity.gor_spend.should == 0
        end
      end
    end
  end
end
