require 'spec_helper'

describe ApplicationHelper do
  before :each do
    organization   = Factory(:organization)
    data_request   = Factory(:data_request, :organization => organization, :start_year => 2009)
    @data_response = organization.latest_response
  end
  describe "#budget_fiscal_year_prev" do
    it "returns '09-10' when data response does not have fiscal year start date" do
      helper.budget_fiscal_year_prev(@data_response).should == '09-10'
    end
  end

  describe "#budget_fiscal_year" do
    it "returns '10-11' when data response have fiscal year dates" do
      helper.budget_fiscal_year(@data_response).should == '10-11'
    end
  end

  describe "#spend_fiscal_year_prev" do
    it "returns '08-09' when data response does not have fiscal year start date" do
      helper.spend_fiscal_year_prev(@data_response).should == '08-09'
    end
  end

  describe "#spend_fiscal_year" do
    it "returns '09-10' when data response have fiscal year dates" do
      helper.spend_fiscal_year(@data_response).should == '09-10'
    end
  end
  
  context "it returns the correct path" do
    describe "activity paths" do
      before :each do
        @project = Factory(:project, :data_response => @data_response)
      end
      it "returns correct path for activities" do
        activity = Factory(:activity, :project => @project, :data_response => @data_response)
        helper.correct_activity_path(activity).should == edit_response_activity_path(@data_response, activity)
      end
      it "returns correct path for other costs" do
        activity = Factory(:other_cost, :project => @project, :data_response => @data_response)
        helper.correct_activity_path(activity).should == edit_response_other_cost_path(@data_response, activity)
      end
      it "returns correct path for sub activities" do
        activity = Factory(:activity, :project => @project, :data_response => @data_response)
        sub_activity = Factory(:sub_activity, :data_response => @data_response, :activity => activity)
        helper.correct_activity_path(sub_activity).should == edit_response_activity_path(@data_response, sub_activity.activity)
      end
    end
  end
end
