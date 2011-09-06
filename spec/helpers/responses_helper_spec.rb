require 'spec_helper'
include ResponsesHelper
include ApplicationHelper

describe "link to unclassified activity" do
  before :each do
    basic_setup_activity
    @activity.stub(:coding_spend_classified?) { true }
    @activity.stub(:coding_spend_district_classified?) { true }
    @activity.stub(:coding_spend_cc_classified?) { true }
    @activity.stub(:coding_budget_classified?) { true }
    @activity.stub(:coding_budget_district_classified?) { true }
    @activity.stub(:coding_budget_cc_classified?) { true }
  end
  it "should link to the activity if there is nothing uncoded" do
    link_to_unclassified(@activity).should == edit_activity_or_ocost_path(@activity)
  end

  it "should link to the locations if locations is uncoded" do
    @activity.stub(:coding_spend_district_classified?) { false }
    @activity.stub(:coding_budget_district_classified?) { false }
    link_to_unclassified(@activity).should == edit_activity_or_ocost_path(@activity, :mode => 'locations')
  end

  it "should link to the locations if locations and purposes are uncoded" do
    @activity.stub(:coding_budget_classified?) { false }
    @activity.stub(:coding_budget_district_classified?) { false }
    link_to_unclassified(@activity).should == edit_activity_or_ocost_path(@activity, :mode => 'locations')
  end

  it "should link to the purposes spend is unclassified and the locations budget is unclassified" do
    @activity.stub(:coding_spend_classified?) { false }
    @activity.stub(:coding_budget_district_classified?) { false }
    link_to_unclassified(@activity).should == edit_activity_or_ocost_path(@activity, :mode => 'purposes')
  end
end
