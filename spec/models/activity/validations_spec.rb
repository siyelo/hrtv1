require File.dirname(__FILE__) + '/../../spec_helper'

describe Activity, "Validations" do
  describe "review screen validations" do
    before :each do
      basic_setup_project
    end

    it "will return true if the activity has a budget" do
      @activity = Factory(:activity, :data_response => @response,
                          :project => @project, :budget => 20, :spend => nil)
      @activity.has_budget_or_spend?.should be_true
    end

    it "will return false if the activity has a spend" do
      @activity = Factory(:activity, :data_response => @response,
                          :project => @project, :budget => nil, :spend => 20)
      @activity.has_budget_or_spend?.should be_true
    end

    it "will return false if the activity has no budget or spend" do
      @activity = Factory(:activity, :data_response => @response,
                          :project => @project, :budget => nil, :spend => nil)
      @activity.has_budget_or_spend?.should be_false
    end
  end
end
