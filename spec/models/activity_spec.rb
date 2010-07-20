require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  
  describe "creating an activity record" do
    subject { Factory(:activity) }
    
    it { should be_valid }
    #it { should validate_presence_of(:name) }
    #TODO
  end
  
  describe "assigning an activity to a project" do
    it "should assign to a project" do
      project      = Factory(:project)
      activity     = Factory(:activity)
      project.activities << activity
      project.activities.should have(1).item
      project.activities.first.should == activity      
    end
  end
  
  describe "can show who we provided money to (providers)" do
    it "should return a providers via projects API" do  
      our_org      = Factory(:organization)
      other_org    = Factory(:organization)
      project      = Factory(:project)
      flow         = Factory(:funding_flow, :from => other_org, :to => our_org, :project => project)
      activity     = Factory(:activity)
      project.activities << activity
      debugger
      activity.valid_providers.should have(1).item
      activity.valid_providers.first.should == @other_org
    end    
  end

  
end
