require File.dirname(__FILE__) + '/../../spec_helper'

describe Activity, "GorAmountHelpers" do

  describe "#gor_budget" do
    context "GOR Fiscal Year" do
      context "all amounts are nil" do
        it "returns 0" do
          attributes = {:budget => nil}
          setup_activity_in_fiscal_year("2010-07-01", "2011-06-30", attributes)
          @activity.gor_budget.should == 0
        end
      end
    end
  end

  describe "#gor_spend" do
    context "GOR Fiscal Year" do
      
      context "all amounts are nil" do
        it "returns 0" do
          attributes = {:spend => nil}
          setup_activity_in_fiscal_year("2010-07-01", "2011-06-30", attributes)
          @activity.gor_spend.should == 0
        end
      end
    end
  end
end
