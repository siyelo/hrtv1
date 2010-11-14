require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  
  describe "creating an activity record" do
    subject { Factory(:activity) }
    
    it { should be_valid }
    it { should have_many :sub_activities }
    it { should have_many :code_assignments }
    it { should have_and_belong_to_many :organizations }
    it { should have_and_belong_to_many :beneficiaries }
    it { should have_and_belong_to_many :locations }
    it { should have_and_belong_to_many :projects }
    it { should belong_to :provider }
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
      comment      = Factory(:comment, :commentable => activity )
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
  
  it "cannot be edited once approved" do
    a = Factory(:activity)
    a.approved.should == nil
    a.approved = true
    a.save!
    a.spend = 2000
    a.save.should == false
  end
  
  describe "finding total spend for strategic objective codes" do
    it "return nothing if no codes assigned to HSSP spend" do
      pending #https://www.pivotaltracker.com/story/show/6115671  
      activity     = Factory(:activity)
      activity.spend_stratobj_coding.should == []
    end
  end
    

   describe "counter cache" do
     it "caches comments count" do
       activity = Factory.create(:activity)
       activity.comments_count.should == 0
       Factory.create(:comment, :commentable => activity)
       activity.reload.comments_count.should == 1
       Factory.create(:comment, :commentable => activity)
       activity.reload.comments_count.should == 2
     end

     it "caches sub activities count" do
       activity = Factory.create(:activity)
       activity.sub_activities_count.should == 0
       Factory.create(:sub_activity, :activity => activity)
       activity.reload.sub_activities_count.should == 1
       Factory.create(:sub_activity, :activity => activity)
       activity.reload.sub_activities_count.should == 2
     end
   end
end
