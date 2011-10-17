require 'spec_helper'

describe ApplicationHelper do
  describe "link to unclassified activity" do
    before :each do
      basic_setup_activity
      @activity.stub(:coding_spend_valid?) { true }
      @activity.stub(:coding_spend_district_valid?) { true }
      @activity.stub(:coding_spend_cc_valid?) { true }
      @activity.stub(:coding_budget_valid?) { true }
      @activity.stub(:coding_budget_district_valid?) { true }
      @activity.stub(:coding_budget_cc_valid?) { true }
    end

    it "should link to the activity if there is nothing uncoded" do
      helper.link_to_unclassified(@activity).should == edit_response_activity_path(@response, @activity)
    end

    it "should link to the locations if locations is uncoded" do
      @activity.stub(:coding_spend_district_valid?) { false }
      @activity.stub(:coding_budget_district_valid?) { false }
      helper.link_to_unclassified(@activity).should == edit_response_activity_path(@response, @activity, :mode => 'locations')
    end

    it "should link to the locations if locations and purposes are uncoded" do
      @activity.stub(:coding_budget_valid?) { false }
      @activity.stub(:coding_budget_district_valid?) { false }
      @activity.stub(:coding_spend_valid?) { false }
      @activity.stub(:coding_spend_district_valid?) { false }
      helper.link_to_unclassified(@activity).should == edit_response_activity_path(@response, @activity, :mode => 'locations')
    end
  end

  describe "#formatted_date" do
    it "should return the date in dd-mm-yy format" do
      date = Date.parse('31-12-2010')
      helper.formatted_date(date).should == "31-12-2010"
    end

    it "should not fail if the date passed is nil" do
      date = nil
      helper.formatted_date(date).should == nil
    end
  end
end
