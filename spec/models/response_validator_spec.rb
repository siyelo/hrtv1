require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../helpers/response_validation_helper'

describe DataResponse do #validations
  before :each do
    @request  = Factory.create(:data_request, :title => 'Data Request 1',
      :budget => true, :spend => true)
    @response = Factory.create(:data_response, :data_request => @request)
    @project = Factory(:project, :data_response => @response, :budget => 100, :spend => 80)
    @response.reload
  end

  describe "Request for only spend" do
    before :each do
      @request.budget = false; @request.save
      @activity   = Factory(:activity_w_spend_coding, :data_response => @response, :project => @project)
      @other_cost = Factory(:other_cost_w_spend_coding, :data_response => @response, :project => @project)
    end

    it_should_behave_like "project spend checker"

    it "fails if project spend is not entered and no quarter spends are" do
      @project.spend = nil; @project.save
      @response.project_amounts_entered?.should == false
    end

    it "is ok if project budget is not entered and no quarter budgets are" do
      @project.budget = nil; @project.save
      @response.project_amounts_entered?.should == true
    end

    it_should_behave_like "activity spend checker"
    it_should_behave_like "coded Activities checker"
    it_should_behave_like "coded OtherCosts checker"
  end

  describe "Request for only budget" do
    before :each do
      @request.spend = false; @request.save
      @activity   = Factory(:activity_w_budget_coding, :data_response => @response, :project => @project)
      @other_cost = Factory(:other_cost_w_budget_coding, :data_response => @response, :project => @project)
    end

    it_should_behave_like "project budget checker"

    it "fails if project budget is not entered and no quarter budgets are" do
      @project.budget = nil; @project.save
      @response.project_amounts_entered?.should == false
    end

    it "is ok if project spend is not entered and no quarter spends are" do
      @project.spend = nil; @project.save
      @response.project_amounts_entered?.should == true
    end

    it_should_behave_like "activity budget checker"
    it_should_behave_like "coded Activities checker"
    it_should_behave_like "coded OtherCosts checker"
  end

  describe "Requesting both budget and spend" do
    before :each do
      @activity   = Factory(:activity_fully_coded, :data_response => @response, :project => @project)
      @other_cost = Factory(:other_cost_fully_coded, :data_response => @response, :project => @project)
    end

    it "succeeds if project has a spend and budget" do
      @response.project_amounts_entered?.should == true
    end
    it_should_behave_like "project spend checker"
    it_should_behave_like "project budget checker"
    it "succeeds if activity has spend and budget" do
      @response.activity_amounts_entered?.should == true
    end
    it_should_behave_like "activity spend checker"
    it_should_behave_like "activity budget checker"
    it_should_behave_like "coded Activities checker"
    it_should_behave_like "coded OtherCosts checker"
  end

  describe "project linking" do
    before :each do
      @funder_response = Factory.create(:data_response, :data_request => @request)
      @funder_project = Factory(:project, :data_response => @funder_response)
    end

    it "succeeds if projects are linked" do
      #TODO link the projects
      funder = Factory(:funding_source, :to => @project.organization,
        :project => @project,
        :from => @funder_response.organization,
        :project_from_id => @funder_project.id,
        :data_response => @response )
      @response.projects_linked?.should == true
    end

    it "fails if no projects exist to link" do
      @response.projects_linked?.should == false
    end

    it "fails if projects not linked" do
      funder = Factory(:funding_source, :to => @project.organization,
        :project => @project,
        :from => @funder_response.organization,
        :data_response => @response )
      @response.projects_linked?.should == false
    end
  end

  describe "ready to submit" do
    before :each do
      @activity   = Factory(:activity_fully_coded, :data_response => @response,
                            :project => @project)
      @other_cost = Factory(:other_cost_fully_coded, :data_response => @response,
                            :project => @project)
      @funder_response = Factory.create(:data_response, :data_request => @request)
      @funder_project = Factory(:project, :data_response => @funder_response,
                                :budget => 100, :spend => 80)
      @funder = Factory(:funding_flow, :to => @project.organization,
        :project => @project,
        :from => @funder_response.organization,
        :project_from_id => @funder_project.id,
        :data_response => @response,
        :budget => 100, :spend => 80)
    end

    it "is OK if everything is entered" do
      @response.projects_entered?.should == true
      @response.project_amounts_entered?.should == true
      @response.projects_linked?.should == true
      @response.activity_amounts_entered?.should == true
      @response.activities_coded?.should == true
      @response.other_costs_coded?.should == true
      @response.projects_have_activities?.should == true
      @response.projects_have_other_costs?.should == true
      @response.projects_and_funding_sources_have_matching_budgets?.should == true
      @response.projects_and_funding_sources_have_correct_spends?.should == true
      @response.projects_and_activities_have_matching_budgets?.should == true
      @response.projects_and_activities_have_matching_spends?.should == true
      @response.ready_to_submit?.should == true
    end

    it "allows submit if everything is coded" do
      @response.submit!.should == true
    end

    context "projects not linked" do
      before :each do
        @funder.project_from_id = nil; @funder.save
      end

      it "succeeds if request not in final review" do
        @request.final_review = false; @request.save; @response.reload
        @response.ready_to_submit?.should == true
      end

      it "fails if in final review " do
        @request.final_review = true; @request.save; @response.reload
        @response.ready_to_submit?.should == false
      end
    end

    it "disallows submit! if not complete" do
      @activity.destroy
      @response.submit!.should == false
    end

    it "fails if no project amounts are entered" do
      @project.spend = @project.budget = nil; @project.save
      @response.project_amounts_entered?.should == false #duplicates of tests above - left for clarity
      @response.ready_to_submit?.should == false
    end

    it "fails if there are no activities" do
      @activity.destroy
      @response.activities_coded?.should == false
      @response.ready_to_submit?.should == false
    end

    it "fails if there are uncoded activities" do
      activity2 = Factory(:activity, :data_response => @response, :project => @project)
      @response.activities_coded?.should == false
      @response.ready_to_submit?.should == false
    end

    it "fails if an activity is missing a coding split" do
      cs = @activity.coding_spend.first
      cs.cached_amount = 0; cs.amount = 0; cs.save! ; @activity.reload
      @response.uncoded_activities.should have(1).item
      @response.activities_coded?.should == false
      @response.ready_to_submit?.should == false
    end

    it "fails if there are uncoded other costs" do
      cs = @other_cost.coding_spend.first
      cs.cached_amount = 0; cs.amount = 0; cs.save!; @other_cost.reload
      @response.other_costs_coded?.should == false
      @response.ready_to_submit?.should == false
    end
  end

  describe "#projects_and_funding_sources_have_matching_budgets?" do
    before :each do
      @funder1     = Factory.create(:organization)
      @funder2     = Factory.create(:organization)
      @implementer = Factory.create(:organization)
      @response    = Factory.create(:data_response, :organization => @implementer)
      @project     = Factory.create(:project, :data_response => @response, :budget => 10)
    end

    it "succeeds if no projects entered" do
      @response.projects_and_funding_sources_have_matching_budgets?.should == true
    end

    it "is true when budget in flow equals to project budget" do
      Factory.create(:funding_flow, :from => @funder1, :to => @implementer,
                     :data_response => @response, :project => @project, :budget => 10)
      @response.projects_and_funding_sources_have_matching_budgets?.should == true
    end

    it "is true when sum of budget in flows is equals to funder budget" do
      setup_funder_equal_to_project(:budget)
      @response.projects_and_funding_sources_have_matching_budgets?.should == true
    end

    it "is false when sum of budget in flows are greated than funder budget" do
      setup_funder_more_than_project(:budget)
      @response.projects_and_funding_sources_have_matching_budgets?.should == false
    end

    it "is false when sum of budget in flows are less than funder budget" do
      setup_funder_less_than_project(:budget)
      @response.projects_and_funding_sources_have_matching_budgets?.should == false
    end
  end

  describe "#projects_and_funding_sources_have_correct_spends?" do
    before :each do
      @funder1 = Factory.create(:organization)
      @funder2 = Factory.create(:organization)
      @implementer = Factory.create(:organization)
      @response    = Factory.create(:data_response, :organization => @implementer)
      @project = Factory.create(:project, :data_response => @response, :spend => 10)
    end

    it "is true when spend in flow equals to project spend" do
      Factory.create(:funding_flow, :from => @funder1, :to => @implementer,
                     :data_response => @response, :project => @project, :spend => 10)
      @response.projects_and_funding_sources_have_correct_spends?.should == true
    end

    it "is true when sum of spend in flows is equals to funder spend" do
      setup_funder_equal_to_project(:spend)
      @response.projects_and_funding_sources_have_correct_spends?.should == true
    end

    it "is false when sum of spend in flows are greater than funder spend" do
      setup_funder_more_than_project(:spend)
      @response.projects_and_funding_sources_have_correct_spends?.should == false
    end

    it "is false when sum of spend in flows are less than funder spend" do
      setup_funder_less_than_project(:spend)
      @response.projects_and_funding_sources_have_correct_spends?.should == false
    end
  end

  describe "#projects_and_activities_have_matching_budgets?" do
    before :each do
      @response = Factory.create(:data_response)
      @project  = Factory.create(:project, :data_response => @response, :budget => 10)
    end

    it "is true when activity budget is equal to project budget" do
      Factory.create(:activity, :project => @project, :budget => 10)
      @response.projects_and_activities_have_matching_budgets?.should == true
      @response.projects_with_activities_not_matching_amounts(:budget).should == []
    end

    it "is true when sum of activities and other cost budgets is equal to project budget" do
      setup_equal_to_project(:budget)
      @response.projects_and_activities_have_matching_budgets?.should == true
      @response.projects_with_activities_not_matching_amounts(:budget).should == []
    end

    it "is true when activities empty and budget is 0" do
      @project.budget = 0 ; @project.save(false)
      @response.projects_and_activities_have_matching_budgets?.should == true
      @response.projects_with_activities_not_matching_amounts(:budget).should == []
    end

    it "is false when sum of activities and other cost budgets is more than to project budget" do
      setup_more_than_project(:budget)
      @response.projects_and_activities_have_matching_budgets?.should == false
      @response.projects_with_activities_not_matching_amounts(:budget).should == [@project]
    end

    it "is false when sum of activities and other cost budgets is less than to project budget" do
      setup_less_than_project(:budget)
      @response.projects_and_activities_have_matching_budgets?.should == false
      @response.projects_with_activities_not_matching_amounts(:budget).should == [@project]
    end
  end

  describe "#projects_and_activities_have_matching_spends?" do
    before :each do
      @response = Factory.create(:data_response)
      @project  = Factory.create(:project, :data_response => @response, :spend => 10)
    end

    it "is true when activity spend is equal to project spend" do
      Factory.create(:activity, :project => @project, :spend => 10)
      @response.projects_and_activities_have_matching_spends?.should == true
    end

    it "is true when activities empty and spend is 0" do
      @project.spend = 0 ; @project.save(false)
      @response.projects_and_activities_have_matching_spends?.should == true
      @response.projects_with_activities_not_matching_amounts(:spend).should == []
    end

    it "is true when sum of activities and other cost spend is equal to project spend" do
      setup_equal_to_project(:spend)
      @response.projects_and_activities_have_matching_spends?.should == true
    end

    it "is false when sum of activities and other cost spend is more than to project spend" do
      setup_more_than_project(:spend)
      @response.projects_and_activities_have_matching_spends?.should == false
    end

    it "is false when sum of activities and other cost spend is less than to project spend" do
      setup_less_than_project(:spend)
      @response.projects_and_activities_have_matching_spends?.should == false
    end
  end
end

#assumes project total is 10
def setup_equal_to_project(field)
  setup_project(field,[2,3,5])
end

def setup_more_than_project(field)
  setup_project(field,[2,3,10])
end

def setup_less_than_project(field)
  setup_project(field,[2,3,3])
end

# quick setup a spend/budget(field) with amounts (activity1, activity2, othercost1)
def setup_project(field, amounts)
  Factory.create(:activity, :project => @project, field => amounts[0])
  Factory.create(:activity, :project => @project, field => amounts[1])
  Factory.create(:other_cost, :project => @project, field => amounts[2])
end


#assumes project total is 10
def setup_funder_equal_to_project(field)
  setup_funders(field,[5,5])
end

def setup_funder_more_than_project(field)
  setup_funders(field,[5,6])
end

def setup_funder_less_than_project(field)
  setup_funders(field,[1,1])
end

# quick setup a spend/budget(field) with amounts (funder1, funder2)
def setup_funders(field, amounts)
  Factory.create(:funding_flow, :from => @funder1, :to => @implementer,
   :data_response => @response, :project => @project, field => amounts[0])
  Factory.create(:funding_flow, :from => @funder2, :to => @implementer,
   :data_response => @response, :project => @project, field => amounts[1])
end
