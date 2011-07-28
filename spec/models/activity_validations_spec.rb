require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
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

  describe "checking activities budget/spend against projects validations" do
    before :each do
      basic_setup_response
    end

    it "returns false when the activitys spend is greater than that of the projects" do
      @project  = Factory(:project, :data_response => @response,
                          :budget => 10000, :spend => 10000)
      @activity = Factory(:activity, :data_response => @response,
                          :project => @project, :spend => 11000, :budget => 9000)
      @activity.check_projects_budget_and_spend?.should be_false
    end

    it "returns false when the activitys budget is greater than that of the projects" do
      @project  = Factory(:project, :data_response => @response,
                          :budget => 10000, :spend => 10000)
      @activity = Factory(:activity, :data_response => @response,
                          :project => @project, :spend => 10000, :budget => 19000)

      @activity.check_projects_budget_and_spend?.should be_false
    end

    it "returns true when the activitys spend and budget is less than that of the projects" do
      @project  = Factory(:project, :data_response => @response,
                          :budget => 10000, :spend => 10000)
      @activity = Factory(:activity, :data_response => @response,
                          :project => @project, :spend => 1000, :budget => 1000)

      @activity.check_projects_budget_and_spend?.should be_true
    end
  end
end
