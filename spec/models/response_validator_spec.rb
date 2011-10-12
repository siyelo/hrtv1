require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../helpers/response_validation_helper'

describe DataResponse do #validations
  before :each do
    @organization = Factory(:organization)
    @request  = Factory.create(:data_request, :organization => @organization)
    @response = @organization.latest_response
    @project  = Factory(:project, :data_response => @response)
    @response.reload
  end

  describe "Request" do
    before :each do
      #need to redo the factories so this test is worth something
      @activity   = Factory(:activity_fully_coded, :data_response => @response, :project => @project)
      @split = Factory.build :implementer_split, :activity => @activity,
        :budget => 40, :spend => 40, :organization => @organization
      @other_cost = Factory(:other_cost_fully_coded, :data_response => @response, :project => @project)
      #@osa        = Factory(:sub_activity, :data_response => @response, :activity => @other_cost, :budget => 40, :spend => 40)
    end

    it "succeeds if activity has spend and budget" do
      @response.activity_amounts_entered?.should be_true
    end
    it_should_behave_like "activity spend checker"
    it_should_behave_like "activity budget checker"
    #it_should_behave_like "coded Activities checker" TODO: enable when we get factories working
    it_should_behave_like "coded OtherCosts checker"
  end

  describe "ready to submit" do
    before :each do
      @activity        = Factory(:classified_activity, :data_response => @response,
                                 :project => @project)
      @other_cost      = Factory(:other_cost_fully_coded, :data_response => @response,
                                 :project => @project)
      @split1 = Factory :implementer_split, :activity => @other_cost,
        :budget => 100, :spend => 100, :organization => @organization
      @other_cost.save
      @other_cost.reload
      @funder_org      = Factory(:organization)
      @request         = Factory(:data_request, :organization => @organization)
      @funder_response = @organization.latest_response
      @funder_project  = Factory(:project, :data_response => @funder_response)
      # the factory should autocreate an in-flow, so we must overwrite it
      @project.in_flows = [Factory.build(:funding_flow, :from => @funder_org,
                            :project_from_id => @funder_project.id, :budget => 100, :spend => 80)]
      @project.save!
      @funder = @project.in_flows.first
    end

    it "returns true if all activities have splits and the splits are valid" do
      @asplit = Factory(:implementer_split, :organization => @organization, :activity => @activity,
                        :budget => 10, :spend => 20)
      @activity.reload
      @activity.save
      @response.implementer_splits_entered_and_valid?.should be_true
    end

    it "returns false if any activity doesn't have splits or a split is invalid" do
      @activity.stub(:implementer_splits).and_return([])
      @other_cost.stub(:implementer_splits).and_return([])
      @response.implementer_splits_entered_and_valid?.should be_false
    end

    it "is OK if everything is entered" do
      @asplit = Factory.build(:implementer_split, :organization => @organization,
        :activity => @activity, :budget => 10, :spend => 20)
      @response.stub(:uncoded_activities) { [] }
      @response.projects_entered?.should be_true
      @response.activity_amounts_entered?.should be_true
      @response.activities_coded?.should be_true
      @response.other_costs_coded?.should be_true
      @response.projects_have_activities?.should be_true
      @response.projects_have_valid_funding_sources?.should be_true
      @response.projects_have_other_costs?.should be_true
      @activity.stub(:implementer_splits).and_return([@asplit])
      @response.stub(:activities).and_return([@activity])
      @response.implementer_splits_entered_and_valid?.should be_true
      @response.ready_to_submit?.should be_true
    end

    it "fails if a project doesn't have an in flow" do
      @project.in_flows.first.destroy
      @project.reload
      @response.projects_have_valid_funding_sources?.should == false
      @response.ready_to_submit?.should == false
    end

    it "fails if an in flow has a 0 budget AND spend" do
      @funder.spend = 0
      @funder.budget = 0
      @funder.save(false)
      @response.projects_have_valid_funding_sources?.should == false
      @response.ready_to_submit?.should == false
    end

    it "fails if there are no activities" do
      @activity.destroy
      @response.activities_coded?.should be_false
      @response.ready_to_submit?.should be_false
    end

    it "fails if there are uncoded activities" do
      activity2 = Factory(:activity, :data_response => @response, :project => @project)
      @split = Factory :implementer_split, :activity => activity2,
        :budget => 54, :organization => @organization
      activity2.reload
      activity2.save
      @response.activities_coded?.should be_false
      @response.ready_to_submit?.should be_false
    end

    it "fails if an activity is missing a coding split" do
      @activity1 = Factory(:activity, :data_response => @response,
                                 :project => @project)
      @split = Factory :implementer_split, :activity => @activity1,
        :budget => 100, :spend => 100, :organization => @organization
      cs = @activity1.coding_spend.first
      @activity1.coding_budget_valid = false
      @activity1.reload
      @activity1.save
      @response.uncoded_activities.should have(1).item
      @response.activities_coded?.should be_false
      @response.ready_to_submit?.should be_false
    end

    it "fails if there are uncoded other costs" do
      @split = Factory.build :implementer_split, :activity => @activity,
        :budget => 54, :organization => @organization
      @other_cost.reload;
      @other_cost.code_assignments = [];
      @other_cost.coding_budget_district_valid = false; #usually happens in a callback
      @other_cost.save!
      @response.reload
      @response.other_costs_coded?.should be_false
      @response.ready_to_submit?.should be_false
    end
  end
end

#assumes project total is 10
def setup_equal_to_project(field)
  setup_project(field,[2000,3000,5000])
end

def setup_more_than_project(field)
  setup_project(field,[2000,3000,10000])
end

def setup_less_than_project(field)
  setup_project(field,[2000,3000,3000])
end

# quick setup a spend/budget(field) with amounts (activity1, activity2, othercost1)
def setup_project(field, amounts)
  Factory(:activity, :data_response => @response, :project => @project, field => amounts[0])
  Factory(:activity, :data_response => @response, :project => @project, field => amounts[1])
  Factory(:other_cost, :data_response => @response, :project => @project, field => amounts[2])
end

#assumes project total is 10
def setup_funder_equal_to_project(field)
  setup_funders(field,[5000,5000])
end

def setup_funder_more_than_project(field)
  setup_funders(field,[5000,6000])
end

def setup_funder_less_than_project(field)
  setup_funders(field,[1000,1000])
end

# quick setup a spend/budget(field) with amounts (funder1, funder2)
def setup_funders(field, amounts)
  @project.in_flows = [Factory.build(:funding_flow, :from => @funder1, field => amounts[0]),
                       Factory.build(:funding_flow, :from => @funder2, field => amounts[1])]
  @project.save!
end
