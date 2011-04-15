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
      @activity   = Factory(:activity_fully_coded,
        :data_response => @response, :project => @project)
      @other_cost = Factory(:other_cost_fully_coded, 
        :data_response => @response, :project => @project)
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
      @activity = classify_the_activity_budget(@response, @project)
      @activity = classify_the_other_cost_budget(@response, @project)
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
      @activity = Factory(:activity_w_spend_coding, 
        :data_response => @response, :project => @project)
      @other_cost = Factory(:other_cost_w_spend_coding, 
        :data_response => @response, :project => @project)
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
    it "returns false if projects not linked" do
      @response.projects_linked?.should == false
      @response.ready_to_submit?.should == false
    end
    it "returns true if projects are linked" do
      link_projects([@project])
      @response.projects_linked?.should == true
    end
  end
  
  describe "ready to submit" do
    it "returns false if there are no activities" do
      @response.activities_coded?.should == false
      @response.ready_to_submit?.should == false
    end
  
    it "returns false if there are uncoded activities" do
      activity = Factory(:activity, :data_response => @response, :project => @project)
      @response.activities_coded?.should == false
      @response.ready_to_submit?.should == false
    end
          
    it "returns true if all activities are coded" do
      #TODO :link projects
      classify_the_activity(@response, @project)       
      classify_the_other_cost(@response, @project)
      @response.ready_to_submit?.should == true
    end 
  
    it "returns true if all activities are coded" do
      #TODO :link projects
      activity, ignore = classify_the_activity(@response, @project)
      activity.classified?.should == true   
      classify_the_other_cost(@response, @project)
      @response.ready_to_submit?.should == true
    end 
  
    it "returns true if all activities are coded" do
      classify_the_other_cost(@response, @project)
      activity, cb, cbd, cbcc, cbsl, csd, cscc, cssl = classify_the_activity(@response, @project)
      cs.cached_amount = 0
      cs.amount = 0
      cs.save!
      activity.reload
      activity.classified?.should == false
      @response.uncoded_activities.should have(1).item
      @response.activities_coded?.should == false        
      @response.ready_to_submit?.should == false
    end
  
    it "returns false if there are uncoded other costs" do
      @response.other_costs_coded?.should == false
      @response.ready_to_submit?.should == false
    end
  
    it "returns true if other costs are coded" do
      #TODO :link projects
      classify_the_other_cost(@response, @project)
      classify_the_activity(@response, @project)
      @response.other_costs_coded?.should == true
      @response.ready_to_submit?.should == true
    end
  end
  
  describe "submitting" do      
    it "fails if not complete" do
      @response.submit!.should == false
    end
    
    it "succeeds when response is fully done" do
      # create projects
      # link projects TODO
      classify_the_other_cost(@response, @project)
      classify_the_activity(@response, @project)
      @response.submit!.should == true
    end
  end
end
