require File.dirname(__FILE__) + '/../spec_helper'

describe DataResponse do #validations

  before :each do
    @request  = Factory.create(:data_request, :title => 'Data Request 1',
      :budget => true, :spend => true)
    @response = Factory.create(:data_response, :data_request => @request)
    @project = Factory(:project, :data_response => @response)
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
    it "succeeds if projects are linked" do
      #TODO link the projects
      funder_response = Factory.create(:data_response, :data_request => @request)
      funder_project = Factory(:project, :data_response => funder_response)
      funder = Factory(:funding_source, :to => @project.organization, 
        :project => @project, 
        :from => funder_response.organization,
        :project_from_id => funder_project,
        :data_response => @response )
      
      @response.projects_linked?.should == true
    end
    
    it "fails if projects not linked" do
      @response.projects_linked?.should == false
    end
  end

  describe "ready to submit" do
    it "succeeds if everything is coded" do
      #TODO link the project.
      activity   = Factory(:activity_fully_coded, :data_response => @response, :project => @project)
      other_cost = Factory(:other_cost_fully_coded, :data_response => @response, :project => @project)
      @response.activities_coded?.should == true
      @response.other_costs_coded?.should == true
      @response.ready_to_submit?.should == true
    end
    
    context "projects not linked" do
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
    
    it "fails if there are no activities" do
      @response.activities_coded?.should == false
      @response.ready_to_submit?.should == false
    end

    it "fails if there are uncoded activities" do
      activity = Factory(:activity, :data_response => @response, :project => @project)
      @response.activities_coded?.should == false
      @response.ready_to_submit?.should == false
    end

    it "fails if an activity is missing a coding split" do
      activity   = Factory(:activity_fully_coded, :data_response => @response, :project => @project)
      other_cost = Factory(:other_cost_fully_coded, :data_response => @response, :project => @project)
      cs = activity.coding_spend.first
      cs.cached_amount = 0
      cs.amount = 0
      cs.save!
      activity.reload
      activity.classified?.should == false
      @response.uncoded_activities.should have(1).item
      @response.activities_coded?.should == false
      @response.ready_to_submit?.should == false
    end

    it "fails if there are uncoded other costs" do
      @response.other_costs_coded?.should == false
      @response.ready_to_submit?.should == false
    end
  end

  describe "submitting" do
    it "succeeds when response is fully done" do
      # create projects
      # link projects TODO
      activity   = Factory(:activity_fully_coded, :data_response => @response, :project => @project)
      other_cost = Factory(:other_cost_fully_coded, :data_response => @response, :project => @project)
      @response.submit!.should == true
    end

    it "fails if not complete" do
      @response.submit!.should == false
    end
  end
end
