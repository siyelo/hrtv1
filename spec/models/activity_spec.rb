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
  
  describe "commenting on an activity" do
    it "should assign to an activity" do
      activity     = Factory(:activity)
      comment     = Factory(:comment)
      activity.comments << comment
      activity.comments.should have(1).item
      activity.comments.first.should == comment
    end
  end
  
  describe "can show who we provided money to (providers)" do
    context "on a single project" do
      it "should have at least 1 provider" do  
        our_org      = Factory(:organization)
        other_org    = Factory(:organization)
        project      = Factory(:project)
        flow         = Factory(:funding_flow, :from => our_org, 
                                              :to => other_org, 
                                              :project => project)
        activity     = Factory(:activity, { :projects => [project], 
                                            :provider => other_org })
        activity.provider.should == other_org # duh
        activity.projects.should have(1).project         
      end
    end
    
    context "across multiple projects" do
      it "should allow assignment to multiple projects" do
        pending
      end
    end
  end
  
end
