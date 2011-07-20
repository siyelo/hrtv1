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

    it "returns true if an other cost has no project" do
      @other_cost = Factory(:other_cost, :data_response => @response,
                            :project => nil, :spend => 11000, :budget => 9000)

      @other_cost.check_projects_budget_and_spend?.should be_true
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

    it "returns true when the activitys quarterly spend and budget is less than that of the projects" do
      @project  = Factory(:project, :data_response => @response,
                          :budget => 10000, :spend => 10000)
      @activity = Factory(:activity, :data_response => @response, :project => @project,
                          :spend_q1 => 1100, :spend_q2 => 1200,
                          :spend_q3 => 1300, :spend_q4 => nil,
                          :budget_q1 => 1100,:budget_q2 => 1100,
                          :budget_q3 => 1100,:budget_q4 => 1100)
      @activity.check_projects_budget_and_spend?.should be_true
    end

    it "returns false when the activitys quarterly spend and budget is greater than that of the projects" do
      @project  = Factory(:project, :data_response => @response,
                          :budget => 10, :spend => 10)
      @activity = Factory(:activity, :data_response => @response, :project => @project,
                          :spend_q1 => 1100, :spend_q2 => 1200,
                          :spend_q3 => 1300, :spend_q4 => nil,
                          :budget_q1 => 1100,:budget_q2 => 1100,
                          :budget_q3 => 1100,:budget_q4 => 1100)
      @activity.check_projects_budget_and_spend?.should be_false
    end
  end
end
