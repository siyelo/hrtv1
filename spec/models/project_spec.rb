require File.dirname(__FILE__) + '/../spec_helper'
require 'set'

describe Project do

  describe "associations" do
    it { should belong_to(:data_response) }
    it { should have_and_belong_to_many(:locations) }
    it { should have_many(:activities).dependent(:destroy) }
    it { should have_many(:other_costs).dependent(:destroy) }
    it { should have_many(:normal_activities).dependent(:destroy) }
    it { should have_many(:funding_flows).dependent(:destroy) }
    it { should have_many(:in_flows) }
    it { should have_many(:out_flows) }
    it { should have_many(:comments) }
    it { should have_many(:funding_sources) }
    it { should have_many(:providers) }
  end

  describe "attributes" do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:description) }
    it { should allow_mass_assignment_of(:spend) }
    it { should allow_mass_assignment_of(:budget) }
    it { should allow_mass_assignment_of(:entire_budget) }
    it { should allow_mass_assignment_of(:start_date) }
    it { should allow_mass_assignment_of(:end_date) }
    it { should allow_mass_assignment_of(:currency) }
    it { should allow_mass_assignment_of(:data_response) }
    it { should allow_mass_assignment_of(:activities) }
    it { should allow_mass_assignment_of(:funding_flows_attributes) }
  end

  describe "validations" do
    subject { Factory(:project) }
    it { should be_valid }
    it { should have_and_belong_to_many :locations }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:data_response_id) }
    it { should validate_presence_of(:data_response_id) }
    it { should allow_value(123.45).for(:budget) }
    it { should allow_value(123.45).for(:spend) }
    it { should allow_value(123.45).for(:entire_budget) }
    it { should allow_value('2010-12-01').for(:start_date) }
    it { should allow_value('2010-12-01').for(:end_date) }
    it { should_not allow_value('').for(:start_date) }
    it { should_not allow_value('').for(:end_date) }
    it { should_not allow_value('2010-13-01').for(:start_date) }
    it { should_not allow_value('2010-12-41').for(:start_date) }
    it { should_not allow_value('2010-13-01').for(:end_date) }
    it { should_not allow_value('2010-12-41').for(:end_date) }

    it "should remove commas from decimal fields on save" do
      [:spend, :budget, :entire_budget].each do |f|
        p = Project.new
        p.send(f.to_s + "=", "10,783,000.32")
        p.save
        p.send(f).should == 10783000.32
      end
    end

    it "should have a valid data_response " do
      project = Factory(:project)
      project.data_response.should_not be_nil
    end

    it "should return the owning organization " do
      project = Factory(:project)
      lambda {project.organization}.should_not raise_error
    end

    it " should NOT create workflow records after save" do
      proj  = Factory(:project)
      proj.funding_flows.should have(0).items
    end
  end

  context "Funding flows: " do
    before(:each) do
      @our_org       = Factory(:organization)
      @data_response = Factory(:data_response,
                                :organization => @our_org)
      @other_org     = Factory(:organization)
      @project       = Factory(:project,
                                :data_response => @data_response )
    end

    it "assigns and returns a sole funding source" do
      flow      = Factory(:funding_flow,
                          :from          => @other_org,
                          :to            => @our_org,
                          :project       => @project,
                          :data_response => @project.data_response)
      @project.reload
      @project.in_flows.first.should == flow
      @project.funding_sources.first.should == @other_org
    end

    it "assigns and returns a sole implementer" do
      flow         = Factory(:funding_flow,
                            :from          => @our_org,
                            :to            => @other_org,
                            :project       => @project,
                            :data_response => @project.data_response)

      @project.reload
      @project.out_flows.first.should == flow
      @project.implementers.first.should == @other_org
      @project.providers.first.should == @other_org     #GR: deprecate me!
    end
  end

  describe "multi-field validations" do
    it "accepts start date < end date" do
      p = Factory.build(:project,
                        :start_date => DateTime.new(2010, 01, 01),
                        :end_date =>   DateTime.new(2010, 01, 02) )
      p.should be_valid
    end

    it "does not accept start date > end date" do
      p = Factory.build(:project,
                        :start_date => DateTime.new(2010, 01, 02),
                        :end_date =>   DateTime.new(2010, 01, 01) )
      p.should_not be_valid
    end

    it "does not accept start date = end date" do
      p = Factory.build(:project,
                        :start_date => DateTime.new(2010, 01, 01),
                        :end_date =>   DateTime.new(2010, 01, 01) )
      p.should_not be_valid
    end

    it "accepts Total Budget >= Total Budget" do
      p = Factory.build(:project,
                        :start_date => DateTime.new(2010, 01, 01),
                        :end_date =>   DateTime.new(2010, 01, 02),
                        :entire_budget => 900,
                        :budget =>        800 )
      p.should be_valid
    end

    it "accepts Total Budget = Total Budget" do
      p = Factory.build(:project,
                      :start_date => DateTime.new(2010, 01, 01),
                      :end_date =>   DateTime.new(2010, 01, 02),
                        :entire_budget => 900,
                        :budget =>        900 )
      p.should be_valid
    end

    it "does not accept Total Budget < Total Budget" do
      p = Factory.build(:project,
                        :start_date => DateTime.new(2010, 01, 01),
                        :end_date =>   DateTime.new(2010, 01, 02),
                        :entire_budget => 900,
                        :budget =>        1000 )
      p.should_not be_valid
    end
  end

  context "on delete" do
    it "should destroy funding flows on delete" do
      project = Factory(:project)
      Factory(:funding_flow,
              :organization_id_from => project.organization,
              :organization_id_to => project.organization,
              :project => project,
              :data_response => project.data_response)

      project.reload # reload project object to be aware of his new funding_flows

      FundingFlow.count.should == 1

      project.destroy
      FundingFlow.count.should == 0
    end
  end

  describe "counter cache" do
    context "comments cache" do
      before :each do
        @commentable = Factory(:project)
      end

      it_should_behave_like "comments_cacher"
    end
  end

  describe "deep cloning" do
    before :each do
      @project = Factory(:project)
      @original = @project #for shared examples
      @a1 = Factory(:activity, :project => @project,
                     :data_response => @project.data_response)
      @a2 = Factory(:activity, :project => @project,
                     :data_response => @project.data_response)
      save_and_deep_clone
    end

    it "should clone associated activities" do
      @clone.activities.count.should == 2
      @clone.activities[0].project.should_not be_nil
      @clone.activities[1].project.should_not be_nil
    end

    it "should have the correct number of activities after the original project is destroyed" do
      @project.destroy
      @clone.reload
      @clone.activities.count.should == 2
      @clone.activities[0].project.should_not be_nil
      @clone.activities[1].project.should_not be_nil
    end

    it_should_behave_like "location cloner"
  end


  describe 'Currency override default' do 
     before :each do
       @project       = Factory(:project, :data_response => Factory(:data_response, :currency => "RWF"))
     end
     it "should return the Data Response currency if no currency overridden" do
       @project.currency.should == 'RWF'
       @project.currency = 'EUR'
       @project.save
       @project.currency.should == 'EUR'
     end
    
    it "should not return blank" do
      @project1       = Factory.build(:project, :data_response => Factory(:data_response, :currency => "GBP"))
      @project1.save
      @project1.currency.should == "GBP"
    end
    
  end

  describe 'Currency cache update' do
    before :each do
      Money.default_bank.add_rate(:RWF, :USD, 0.5)
      Money.default_bank.add_rate(:EUR, :USD, 1.5)

      @data_response = Factory(:data_response, :currency => 'RWF')
      @project       = Factory(:project,
                                :data_response => @data_response,
                                :currency => nil)
      @activity      = Factory(:activity, :project => @project,
                                :budget => 1000, :spend => 2000)

    end

    it "should update cached USD amounts on Activity and Code Assignment" do
      @activity.budget_in_usd.should == 500
      @activity.spend_in_usd.should == 1000
      @project.currency = 'EUR'
      @project.save
      @activity.reload
      @activity.budget_in_usd.should == 1500
      @activity.spend_in_usd.should == 3000
    end
  end

  describe "currency conversion for big amounts" do
    it "should convert large activity amounts back correctly" do
      ONE_HUNDRED_BILLION_DOLLARS = 100000000000.00
      Money.default_bank.add_rate(:USD, :RWF, 500)
      Money.default_bank.add_rate(:RWF, :USD, 0.002)
      activity = Factory.build(:activity)
      project  = activity.project
      project.currency = 'USD'
      project.save
      activity.spend = ONE_HUNDRED_BILLION_DOLLARS
      activity.save
      activity.reload
      activity.spend_in_usd.should == ONE_HUNDRED_BILLION_DOLLARS
      project.currency = 'RWF'
      project.save
      activity.reload
      activity.save
      activity.spend_in_usd.should == ONE_HUNDRED_BILLION_DOLLARS / 500
    end
  end

  describe "#ultimate_funding_sources" do

    before :each do

      @org0 = Factory(:organization, :name => 'org0')
      @org1 = Factory(:organization, :name => 'org1')
      @org2 = Factory(:organization, :name => 'org2')
      @org3 = Factory(:organization, :name => 'org3')
      @org4 = Factory(:organization, :name => 'org4')

      @org_with_no_data_response = Factory(:organization, 
                                           :name => 'org_with_no_data_response')
      @org_with_empty_data_response = Factory(:organization, 
                                              :name => 'org_with_empty_data_response')
      request = Factory(:data_request)

      Factory(:data_response, :organization => @org_with_empty_data_response,
              :data_request => request)
      @response0 = Factory(:data_response, :organization => @org0, :data_request => request)
      @response1 = Factory(:data_response, :organization => @org1,
                          :data_request => request)
      @response2 = Factory(:data_response, :organization => @org2,
                          :data_request => request)
      @response3 = Factory(:data_response, :organization => @org3,
                          :data_request => request)
      @response4 = Factory(:data_response, :organization => @org4,
                          :data_request => request)

      @proj0 = Factory(:project, :data_response => @response0)
      @proj1 = Factory(:project, :data_response => @response1)
      @proj11 = Factory(:project, :data_response => @response1)
      @proj12 = Factory(:project, :data_response => @response1)
      @proj2 = Factory(:project, :data_response => @response2)
      @proj3 = Factory(:project, :data_response => @response3)
      @proj4 = Factory(:project, :data_response => @response4)
    end

    def proj_funded_by(proj, funder, budget = 50, spend = 50)
      to = proj.data_response.organization
      Factory(:funding_flow, :from => funder, :to => to, :project => proj,
               :budget => budget, :spend => spend)
      proj
    end

    def self_funded(proj, budget = 50, spend = 50)
      proj_funded_by(proj, proj.data_response.organization, budget, spend)
    end
   
    def bud_spend_ret(budget, spend)
      
    end

    # helper for next tests; change activities and same conditions hold
    def should_be_org_regardless_of_activities_when_up_has_one_ufs(org, fa)
      ufs = @proj2.ultimate_funding_sources
      ufs.should == [{:ufs => org, :fa => fa, :budget => 50, :spend => 50}]
      
      funder_project = org.projects.first
      Factory(:activity, :project => funder_project, :provider => @org_with_empty_data_response,
                                :data_response => funder_project.data_response)
      ufs = @proj2.ultimate_funding_sources
      ufs.should == [{:ufs => org, :fa => fa, :budget => 50, :spend => 50}]

      funder_project.activities.delete
      Factory(:activity, :project => funder_project, :provider => @org1,
                                :data_response => funder_project.data_response)
      ufs = @proj2.ultimate_funding_sources
      ufs.should == [{:ufs => org, :fa => fa, :budget => 50, :spend => 50}]

      funder_project.activities.delete
      Factory(:activity, :project => funder_project, :provider => @org2,
                                :data_response => funder_project.data_response)
      ufs = @proj2.ultimate_funding_sources
      ufs.should == [{:ufs => org, :fa => fa, :budget => 50, :spend => 50}]
    end
    
    it "returns no UFS if project has no funder" do
      ufs = @proj0.ultimate_funding_sources
      ufs.should == []
    end

    it "returns self as the UFS if project was self-funded" do
      ufs = self_funded(@proj1).ultimate_funding_sources
      ufs.should == [{:ufs => @org1, :fa => @org1, :budget => 50, :spend => 50}]
    end

# rewrite when we get to amounts with correct amounts
# implementing this now may make code later harder
# it "returns self as the UFS if project was self-funded mistakenly twice" do
# self_funded(@proj1)
# ufs =self_funded( @proj1).ultimate_funding_sources
# ufs.should == [@org1]
# end

    it "returns funder as the UFS if has one, non-self funder with no data response" do
      proj_funded_by(@proj1, @org_with_no_data_response, 1, 2)
      ufs = @proj1.ultimate_funding_sources
      ufs.should == [{:ufs => @org_with_no_data_response, :fa => @org1, 
                      :budget => 1, :spend => 2}]
    end

    it "returns funder as the UFS if has one, non-self funder with emtpy data response" do
      proj_funded_by(@proj1, @org_with_empty_data_response, 1, 2)
      ufs = @proj1.ultimate_funding_sources
      ufs.should == [{:ufs => @org_with_empty_data_response, :fa => @org1,
                      :budget => 1, :spend => 2}]
    end

    it "returns n-1 (upstream) funder as the UFS if upstream has one funder with empty dr" do
      proj_funded_by(@proj1, @org_with_empty_data_response, 1, 2)
      proj_funded_by(@proj2, @org1)
      ufs = @proj2.ultimate_funding_sources
      ufs.should == [{:ufs => @org_with_empty_data_response, :fa => @org1,
                      :budget => 1, :spend => 2}]
    end

    it "returns n-1 (upstream) funder as the UFS if upstream has one funder with no dr" do
      proj_funded_by(@proj1, @org_with_no_data_response, 1, 2)
      proj_funded_by(@proj2, @org1)
      ufs = @proj2.ultimate_funding_sources
      ufs.should == [{:ufs => @org_with_no_data_response, :fa => @org1,
                      :budget => 1, :spend => 2}]
    end

    it "returns n-1 (upstream=up) funder as the UFS if up is self-funded regardless of up's activities" do
      self_funded(@proj1)
      proj_funded_by(@proj2, @org1)
      should_be_org_regardless_of_activities_when_up_has_one_ufs(@org1, @org2)
    end
    
    it "returns n-1 (upstream) funder as the UFS if upstream has one funder regardless of up's activities" do
      proj_funded_by(@proj1, @org0)
      proj_funded_by(@proj2, @org1)
      should_be_org_regardless_of_activities_when_up_has_one_ufs(@org0, @org1)
    end

    it "returns only self when project self-funded even if org has many other projs with other funders" do
      proj_funded_by(@proj1, @org1, 1, 2)
      proj_funded_by(@proj12, @org0)
      proj_funded_by(@proj11, @org2)
      ufs = @proj1.ultimate_funding_sources
      ufs.should == [{:ufs => @org1, :fa => @org1, :budget => 1, :spend => 2}]
    end
# some donors didn't self fund themselves so show up as both a funding source and the funder they put for their own activities (CDC gives CDC + USG/PEPFAR) for proj 108
# it "returns the donor as funder if donor does not have any activities for the downstream" do
# proj_funded_by(@proj1, @org1)
# proj_funded_by(@proj12, @org0)
# proj_funded_by(@proj11, @org2)
# ufs = @proj1.ultimate_funding_sources
#      ufs.should == [@org1]
# end

# potentially meaningful edge case
# it "detects flows that organizations did not self report but donor did" do
# proj_funded_by(@proj1, @org1)
# Factory.create(:activity, :project => @proj1, :provider => @org2,
# :data_response => @proj1.data_response)
# #proj2 has no activities or funders
# ufs = @proj2.ultimate_funding_sources
#      ufs.should == [@org1]
# end

# it "does not detects flows that implementer reported but donor did not when implementer reported funding sources for a project" do
# proj_funded_by(@proj2, @org1)
# proj_funded_by(@proj1, @org0)
# ufs = @proj2.ultimate_funding_sources
#      ufs.should == [@org1]
# end

    it "returns both n-1 upstream sources for a single project" do
      proj_funded_by(@proj3, @org1, 1, 2)
      proj_funded_by(@proj3, @org2, 11, 22)
      @proj3.ultimate_funding_sources.sort_by{ |e| e[:ufs].id }.should == [
        {:ufs => @org1, :fa => @org3, :budget => 1, :spend => 2}, 
        {:ufs => @org2, :fa => @org3, :budget => 11, :spend => 22}
      ]
    end
    
    it "returns both n-1 upstream sources with different amts for a single project" do
      @proj3.spend = @proj3.budget = 100
      proj_funded_by(@proj3, @org1, 50, 75)
      proj_funded_by(@proj3, @org2, 50, 25)
      @proj3.ultimate_funding_sources.sort_by{ |e| e[:ufs].id }.should == [
        {:ufs => @org1, :fa => @org3, :budget => 50, :spend => 75}, 
        {:ufs => @org2, :fa => @org3, :budget => 50, :spend => 25}]
    end

    it "returns the n-2 upstream funder as the UFS" do
      proj_funded_by(@proj2, @org1, 1, 2)
      proj_funded_by(@proj3, @org2)
      ufs = @proj3.ultimate_funding_sources
      ufs.should == [{:ufs => @org1, :fa => @org2, :budget => 1, :spend => 2}]
    end
    
    it "returns both n-2 upstream funders as the UFS's" do
      proj_funded_by(@proj3, @org1, 1, 2)
      proj_funded_by(@proj3, @org2, 10, 20)
      proj_funded_by(@proj4, @org3)
      @proj4.ultimate_funding_sources{ |e| e.id }.should == [
        {:ufs => @org1, :fa => @org3, :budget => 1, :spend => 2}, 
        { :ufs => @org2, :fa => @org3, :budget => 10, :spend => 20}]
    end
    
    it "returns both n-2 upstream funders as the UFS's" do
      @proj3.spend = @proj3.budget = 1000
      @proj4.spend = @proj4.budget = 100
      proj_funded_by(@proj3, @org1, 25, 50)
      proj_funded_by(@proj3, @org2, 75, 50)
      proj_funded_by(@proj4, @org3, 10, 10)
      @proj4.ultimate_funding_sources{ |e| e.id }.should == [
        {:ufs => @org1, :fa => @org3, :budget => 25, :spend => 50}, 
        {:ufs => @org2, :fa => @org3, :budget => 75, :spend => 50}]
    end

    it "cant disambiguate funders without activities in projects of n-1 upstream for UFS" do
      proj_funded_by(@proj11, @org1, 1, 2)
      proj_funded_by(@proj12, @org2, 10, 20)
      proj_funded_by(@proj3, @org1)
      @proj3.ultimate_funding_sources{ |e| e[0].id }.should == [
        {:ufs => @org1, :fa => @org3, :budget => 1, :spend => 2}, 
        {:ufs => @org2, :fa => @org1, :budget => 10, :spend => 20}]
    end

    it "disambiguates funders with activities in projects of n-1 upstream for UFS" do
      self_funded(@proj1)
      proj_funded_by(@proj11, @org1)
      proj_funded_by(@proj12, @org2, 1, 2)
      proj_funded_by(@proj3, @org1)
      Factory.create(:activity, :project => @proj12, :provider => @org3,
                                :data_response => @proj12.data_response)
      ufs = @proj3.ultimate_funding_sources
      ufs.should == [{:ufs => @org2, :fa => @org1, :budget => 1, :spend => 2}]
    end

    it "uses activities in projects of n-1 upstream for UFS as it goes up" do
      proj_funded_by(@proj11, @org1)
      proj_funded_by(@proj12, @org2)
      proj_funded_by(@proj2, @org0, 1, 2) #UFS of org2 is org0
      proj_funded_by(@proj3, @org1)
      @proj31 = Factory(:project, :data_response => @response3)
      
      Factory.create(:activity, :project => @proj12, :provider => @org3,
                                :data_response => @proj12.data_response)
      ufs = @proj3.ultimate_funding_sources
      ufs.should == [{:ufs => @org0, :fa => @org2, :budget => 1, :spend => 2}]
    end

    it "returns funder and intermediate as UFSs when funder does not have any in flows and intermediate has more out flows than in flows" do
      # lets have it log an error / inconsistency in data and continue as if data is okay
      # NOT adding the intermediary in but just using it's UFS
      Factory(:funding_flow, :from => @org1, :to => @org2, :project => @proj2,
        :budget => 1, :spend => 2)
      Factory(:funding_flow, :from => @org2, :to => @org3, :project => @proj3,
        :budget => 50)
      ufs = @proj3.ultimate_funding_sources
      ufs.should == [{:ufs => @org1, :fa => @org2, :budget => 1, :spend => 2}]
      # TEST that error was logged
    end

    it "returns real UFS if it's implementer of an activity of funded organization" do
      @proj21 = Factory(:project, :data_response => @response2)
      @proj22 = Factory(:project, :data_response => @response2)

      # organization 1
      Factory(:funding_flow, :from => @org1, :to => @org1, :project => @proj1,
              :budget => 100, :spend => 100)
      Factory(:activity, :project => @proj1, :provider => @org2,
                     :data_response => @response1)

      # organization 2
      Factory(:funding_flow, :from => @org1, :to => @org2, :project => @proj21,
              :budget => 30, :spend => 30)
      Factory(:funding_flow, :from => @org2, :to => @org2, :project => @proj22,
              :budget => 70, :spend => 70)
      Factory(:activity, :project => @proj21, :provider => @org3,
                     :data_response => @response2)

      # organization 3
      Factory(:funding_flow, :from => @org2, :to => @org3, :project => @proj3,
              :budget => 30, :spend => 30)

      ufs = @proj3.ultimate_funding_sources
      p ufs[0][:budget].to_s
      ufs.should == [{:ufs => @org1, :fa => @org2, :budget => 30, :spend => 30}]
    end

    it "returns real UFS if it's implementer of an activity of self-funded organization" do
      # organization 2
      Factory(:funding_flow, :from => @org2, :to => @org2, :project => @proj2,
              :budget => 50, :spend => 50)
      activity = Factory(:activity, :project => @proj2, :provider => @org3,
                                :data_response => @response2)

      # organization 3
      Factory(:funding_flow, :from => @org2, :to => @org3, :project => @proj3,
              :budget => 1, :spend => 2)

      ufs = @proj3.ultimate_funding_sources
      ufs.should == [{:ufs => @org2, :fa => @org3, :budget => 1, :spend => 2}]
    end
    
    it "walks up donor as usual if matching activity is found for it in donor data response" do
      # organization 2 is donor
      @org2.raw_type = "Donor"; @org2.save
      Factory(:funding_flow, :from => @org0, :to => @org2, :project => @proj2,
              :budget => 1, :spend => 2)
      activity = Factory(:activity, :project => @proj2, :provider => @org3,
                         :budget => 50, :data_response => @response2)

      # organization 3
      Factory(:funding_flow, :from => @org2, :to => @org3, :project => @proj3,
              :budget => 50, :spend => 50)

      ufs = @proj3.ultimate_funding_sources
      ufs.should == [{:ufs => @org0, :fa => @org2, :budget => 1, :spend => 2}]
    end

    it "gives donor as real UFS if no matching activity is found for it in donor data response" do
      # organization 2 is donor
      @org2.raw_type = "Donor"; @org2.save
      Factory(:funding_flow, :from => @org0, :to => @org2, :project => @proj2,
              :budget => 50, :spend => 50)

      # organization 3
      Factory(:funding_flow, :from => @org2, :to => @org3, :project => @proj3,
              :budget => 1, :spend => 2)

      ufs = @proj3.ultimate_funding_sources
      ufs.should == [{:ufs => @org2, :fa => @org3, :budget => 1, :spend => 2}]
    end
  end
end
