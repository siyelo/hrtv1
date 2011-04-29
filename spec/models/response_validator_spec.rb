require File.dirname(__FILE__) + '/../spec_helper'

describe DataResponse do #validations

  before :each do
    @request  = Factory.create(:data_request, :title => 'Data Request 1',
      :budget => true, :spend => true)
    @response = Factory.create(:data_response, :data_request => @request)
    @project = Factory(:project, :data_response => @response, :budget => 100, :spend => 80)
    @response.reload
  end

  describe "Request for both budget and spend" do
    before :each do
      @activity   = Factory(:activity_fully_coded, :data_response => @response, :project => @project)
      @other_cost = Factory(:other_cost_fully_coded, :data_response => @response, :project => @project)
    end

    it "checks Activity budget and spends if Request.budget & spend is set" do
      @response.uncoded_activities.should be_empty
      @response.activities_coded?.should == true
    end

    it "checks Other Costs budget and spends if Request.budget & spend is set" do
      @response.uncoded_other_costs.should be_empty
      @response.other_costs_coded?.should == true
    end
  end

  describe "Request for only budget" do
    before :each do
      @request.spend = false
      @request.save
      @activity   = Factory(:activity_w_budget_coding, :data_response => @response, :project => @project)
      @other_cost = Factory(:other_cost_w_budget_coding, :data_response => @response, :project => @project)
    end

    it "is sane" do
      @activity.spend_classified?.should == false
      @activity.budget_classified?.should == true
    end

    it "checks only the Activity budget codings" do
      @response.uncoded_activities.should be_empty
      @response.activities_coded?.should == true
    end

    it "checks only the Activity spend codings" do
      @response.uncoded_other_costs.should be_empty
      @response.other_costs_coded?.should == true
    end
  end

  describe "Request for only spend" do
    before :each do
      @request.budget = false
      @request.save
      @activity   = Factory(:activity_w_spend_coding, :data_response => @response, :project => @project)
      @other_cost = Factory(:other_cost_w_spend_coding, :data_response => @response, :project => @project)
    end

    it "is sane" do
      @activity.spend_classified?.should == true
      @activity.budget_classified?.should == false
    end

    it "checks only the Activity spend codings" do
      @response.uncoded_activities.should be_empty
      @response.activities_coded?.should == true
    end

    it "checks only the Other Cost spend codings" do
      @response.uncoded_other_costs.should be_empty
      @response.other_costs_coded?.should == true
    end
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
  
  describe "project spend check" do    
    it "succeeds if spend is entered" do
      @response.projects_spend_entered?.should == true
    end
    
    it "succeeds if spend not entered but a quarter spend is" do
      @project.spend = nil
      @project.spend_q1 = 10
      @project.save
      @response.projects_spend_entered?.should == true
    end
    
    it "fails if spend is not entered and no quarter spends are" do
      @project.spend = nil
      @project.save
      @response.projects_spend_entered?.should == false
    end
  end

  describe "project budget check" do    
    it "succeeds if budget is entered" do
      @response.projects_budget_entered?.should == true
    end
    
    it "succeeds if budget not entered but a quarter budget is" do
      @project.budget = nil
      @project.budget_q1 = 10
      @project.save
      @response.projects_budget_entered?.should == true
    end
    
    it "fails if budget is not entered and no quarter budgets are" do
      @project.budget = nil
      @project.save
      @response.projects_budget_entered?.should == false
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
    
    context "response is complete" do
      it "validates OK if everything is entered" do
        @response.projects_entered?.should == true
        @response.projects_spend_entered?.should == true
        @response.projects_budget_entered?.should == true
        @response.projects_linked?.should == true
        @response.activities_coded?.should == true
        @response.other_costs_coded?.should == true

        @response.projects_have_activities?.should == true
        @response.projects_have_other_costs?.should == true
        @response.projects_and_funding_sources_have_correct_budgets?.should == true
        @response.projects_and_funding_sources_have_correct_spends?.should == true
        @response.projects_and_activities_have_correct_budgets?.should == true
        @response.projects_and_activities_have_correct_spends?.should == true

        @response.ready_to_submit?.should == true
      end
      
      it "submits if everything is coded" do
        @response.submit!.should == true
      end
      
    end
    
    context "projects not linked" do
      before :each do
        @funder.project_from_id = nil
        @funder.save
      end
      
      it "succeeds if request not in final review" do
        @request.final_review = false
        @request.save
        @response.reload
        @response.ready_to_submit?.should == true
      end
      
      it "fails if in final review " do
        @request.final_review = true
        @request.save
        @response.reload
        @response.ready_to_submit?.should == false
      end
    end
    
    it "disallows submit! if not complete" do
      @activity.destroy
      @response.submit!.should == false
    end
    
    it "fails if project spends are not entered" do
      @project.spend = nil
      @project.save
      @response.projects_spend_entered?.should == false
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
      cs.cached_amount = 0
      cs.amount = 0
      cs.save!
      @activity.reload
      @response.uncoded_activities.should have(1).item
      @response.activities_coded?.should == false
      @response.ready_to_submit?.should == false
    end

    it "fails if there are uncoded other costs" do
      cs = @other_cost.coding_spend.first
      cs.cached_amount = 0
      cs.amount = 0
      cs.save!
      @other_cost.reload
      @response.other_costs_coded?.should == false
      @response.ready_to_submit?.should == false
    end
  end

  describe "#projects_and_funding_sources_have_correct_budgets?" do
    before :each do
      @funder1 = Factory.create(:organization)
      @funder2 = Factory.create(:organization)
      @implementer = Factory.create(:organization)
      @response    = Factory.create(:data_response, :organization => @implementer)
      @project = Factory.create(:project, :data_response => @response, :budget => 10)
    end
    
    it "succeeds if no projects entered" do
      @response.projects_and_funding_sources_have_correct_budgets?.should == true
    end

    it "is true when budget in flow equals to project budget" do
      Factory.create(:funding_flow, :from => @funder1, :to => @implementer,
                     :data_response => @response, :project => @project, :budget => 10)

      @response.projects_and_funding_sources_have_correct_budgets?.should == true
    end

    it "is true when sum of budget in flows is equals to funder budget" do
      Factory.create(:funding_flow, :from => @funder1, :to => @implementer,
                     :data_response => @response, :project => @project, :budget => 5)
      Factory.create(:funding_flow, :from => @funder2, :to => @implementer,
                     :data_response => @response, :project => @project, :budget => 5)

      @response.projects_and_funding_sources_have_correct_budgets?.should == true
    end

    it "is false when sum of budget in flows are greated than funder budget" do
      Factory.create(:funding_flow, :from => @funder1, :to => @implementer,
                     :data_response => @response, :project => @project, :budget => 5)
      Factory.create(:funding_flow, :from => @funder2, :to => @implementer,
                     :data_response => @response, :project => @project, :budget => 6)

      @response.projects_and_funding_sources_have_correct_budgets?.should == false
    end

    it "is false when sum of budget in flows are less than funder budget" do
      Factory.create(:funding_flow, :from => @funder1, :to => @implementer,
                     :data_response => @response, :project => @project, :budget => 5)
      Factory.create(:funding_flow, :from => @funder2, :to => @implementer,
                     :data_response => @response, :project => @project, :budget => 6)

      @response.projects_and_funding_sources_have_correct_budgets?.should == false
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
      Factory.create(:funding_flow, :from => @funder1, :to => @implementer,
                     :data_response => @response, :project => @project, :spend => 5)
      Factory.create(:funding_flow, :from => @funder2, :to => @implementer,
                     :data_response => @response, :project => @project, :spend => 5)

      @response.projects_and_funding_sources_have_correct_spends?.should == true
    end

    it "is false when sum of spend in flows are greated than funder spend" do
      Factory.create(:funding_flow, :from => @funder1, :to => @implementer,
                     :data_response => @response, :project => @project, :spend => 5)
      Factory.create(:funding_flow, :from => @funder2, :to => @implementer,
                     :data_response => @response, :project => @project, :spend => 6)

      @response.projects_and_funding_sources_have_correct_spends?.should == false
    end

    it "is false when sum of spend in flows are less than funder spend" do
      Factory.create(:funding_flow, :from => @funder1, :to => @implementer,
                     :data_response => @response, :project => @project, :spend => 5)
      Factory.create(:funding_flow, :from => @funder2, :to => @implementer,
                     :data_response => @response, :project => @project, :spend => 6)

      @response.projects_and_funding_sources_have_correct_spends?.should == false
    end
  end

  describe "#projects_and_activities_have_correct_budgets?" do
    before :each do
      @response = Factory.create(:data_response)
      @project  = Factory.create(:project, :data_response => @response, :budget => 10)
    end

    it "is true when activity budget is equal to project budget" do
      Factory.create(:activity, :project => @project, :budget => 10)

      @response.projects_and_activities_have_correct_budgets?.should == true
    end

    it "is true when sum of activities and other cost budgets is equal to project budget" do
      Factory.create(:activity, :project => @project, :budget => 2)
      Factory.create(:activity, :project => @project, :budget => 3)
      Factory.create(:other_cost, :project => @project, :budget => 5)

      @response.projects_and_activities_have_correct_budgets?.should == true
    end

    it "is false when sum of activities and other cost budgets is more than to project budget" do
      Factory.create(:activity, :project => @project, :budget => 2)
      Factory.create(:activity, :project => @project, :budget => 3)
      Factory.create(:other_cost, :project => @project, :budget => 10)

      @response.projects_and_activities_have_correct_budgets?.should == false
    end

    it "is false when sum of activities and other cost budgets is less than to project budget" do
      Factory.create(:activity, :project => @project, :budget => 2)
      Factory.create(:activity, :project => @project, :budget => 3)
      Factory.create(:other_cost, :project => @project, :budget => 3)

      @response.projects_and_activities_have_correct_budgets?.should == false
    end
  end

  describe "#projects_and_activities_have_correct_spends?" do
    before :each do
      @response = Factory.create(:data_response)
      @project  = Factory.create(:project, :data_response => @response, :spend => 10)
    end

    it "is true when activity spend is equal to project spend" do
      Factory.create(:activity, :project => @project, :spend => 10)

      @response.projects_and_activities_have_correct_spends?.should == true
    end

    it "is true when sum of activities and other cost spend is equal to project spend" do
      Factory.create(:activity, :project => @project, :spend => 2)
      Factory.create(:activity, :project => @project, :spend => 3)
      Factory.create(:other_cost, :project => @project, :spend => 5)

      @response.projects_and_activities_have_correct_spends?.should == true
    end

    it "is false when sum of activities and other cost spend is more than to project spend" do
      Factory.create(:activity, :project => @project, :spend => 2)
      Factory.create(:activity, :project => @project, :spend => 3)
      Factory.create(:other_cost, :project => @project, :spend => 10)

      @response.projects_and_activities_have_correct_spends?.should == false
    end

    it "is false when sum of activities and other cost spend is less than to project spend" do
      Factory.create(:activity, :project => @project, :spend => 2)
      Factory.create(:activity, :project => @project, :spend => 3)
      Factory.create(:other_cost, :project => @project, :spend => 3)

      @response.projects_and_activities_have_correct_spends?.should == false
    end
  end

end
