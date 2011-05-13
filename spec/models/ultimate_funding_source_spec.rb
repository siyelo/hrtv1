require File.dirname(__FILE__) + '/../spec_helper'
require 'set'

describe Project do

  describe "#ultimate_funding_sources" do
    before :each do
      ufs_test_setup
    end

    # helper for next tests; change activities and same conditions hold
    def should_be_org_regardless_of_activities_when_up_has_one_ufs(org, fa)
      ufs = @proj2.ultimate_funding_sources
      ufs_without_chains(ufs).should == [{:ufs => org, :fa => fa, :budget => 50, :spend => 50}]

      funder_project = org.projects.first
      Factory(:activity, :project => funder_project, :provider => @org_with_empty_data_response,
                                :data_response => funder_project.data_response)
      ufs = @proj2.ultimate_funding_sources
      ufs_without_chains(ufs).should == [{:ufs => org, :fa => fa, :budget => 50, :spend => 50}]

      funder_project.activities.delete
      Factory(:activity, :project => funder_project, :provider => @org1,
                                :data_response => funder_project.data_response)
      ufs = @proj2.ultimate_funding_sources
      ufs_without_chains(ufs).should == [{:ufs => org, :fa => fa, :budget => 50, :spend => 50}]

      funder_project.activities.delete
      Factory(:activity, :project => funder_project, :provider => @org2,
                                :data_response => funder_project.data_response)
      ufs = @proj2.ultimate_funding_sources
      ufs_without_chains(ufs).should == [{:ufs => org, :fa => fa, :budget => 50, :spend => 50}]
    end


    it "returns no UFS if project has no funder" do
      ufs = @proj0.ultimate_funding_sources
      ufs_without_chains(ufs).should == []
    end

    it "returns self as the UFS if project was self-funded" do
      ufs = self_funded(@proj1).ultimate_funding_sources
      ufs_without_chains(ufs).should == [{:ufs => @org1, :fa => @org1, :budget => 50, :spend => 50}]
    end

# rewrite when we get to amounts with correct amounts
# implementing this now may make code later harder
# it "returns self as the UFS if project was self-funded mistakenly twice" do
# self_funded(@proj1)
# ufs =self_funded( @proj1).ultimate_funding_sources
# ufs_without_chains(ufs).should == [@org1]
# end

    it "returns funder as the UFS if has one, non-self funder with no data response" do
      proj_funded_by(@proj1, @org_with_no_data_response, 1, 2)
      ufs = @proj1.ultimate_funding_sources
      ufs_without_chains(ufs).should == [{:ufs => @org_with_no_data_response,
        :fa => @org1, :budget => 1, :spend => 2}]
    end

    it "returns funder as the UFS if has one, non-self funder with emtpy data response" do
      proj_funded_by(@proj1, @org_with_empty_data_response, 1, 2)
      ufs = @proj1.ultimate_funding_sources
      ufs_without_chains(ufs).should == [{:ufs => @org_with_empty_data_response,
        :fa => @org1, :budget => 1, :spend => 2}]
    end

    it "returns n-1 (upstream) funder as the UFS if upstream has one funder with empty dr" do
      proj_funded_by(@proj1, @org_with_empty_data_response, 1, 2)
      proj_funded_by(@proj2, @org1, 1, 2)
      ufs = @proj2.ultimate_funding_sources
      ufs_without_chains(ufs).should == [{:ufs => @org_with_empty_data_response,
        :fa => @org1, :budget => 1, :spend => 2}]
    end

    it "returns n-1 (upstream) funder as the UFS if upstream has one funder with no dr" do
      proj_funded_by(@proj1, @org_with_no_data_response, 1, 2)
      proj_funded_by(@proj2, @org1)
      ufs = @proj2.ultimate_funding_sources
      ufs_without_chains(ufs).should == [{:ufs => @org_with_no_data_response,
        :fa => @org1, :budget => 1, :spend => 2}]
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
      ufs_without_chains(ufs).should == [{:ufs => @org1, :fa => @org1, :budget => 1, :spend => 2}]
    end

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
      ufs_without_chains(ufs).should == [{:ufs => @org1, :fa => @org2, :budget => 1, :spend => 2}]
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
      ufs_without_chains(ufs).should == [{:ufs => @org2, :fa => @org1, :budget => 1, :spend => 2}]
    end

    it "uses activities in projects of n-1 upstream for UFS as it goes up" do
      proj_funded_by(@proj11, @org1)
      proj_funded_by(@proj12, @org2)
      proj_funded_by(@proj2, @org0, 1, 2) #UFS of org2 is org0
      proj_funded_by(@proj3, @org1)
      @proj31 = Factory(:project, :data_response => @response3, :currency => "USD")
      Factory(:activity, :project => @proj12, :provider => @org3,
        :data_response => @proj12.data_response)
      ufs = @proj3.ultimate_funding_sources
      ufs_without_chains(ufs).should == [{:ufs => @org0, :fa => @org2, :budget => 1, :spend => 2}]
    end

    it "returns funder and intermediate as UFSs when funder does not have any in flows and intermediate has more out flows than in flows" do
      # lets have it log an error / inconsistency in data and continue as if data is okay
      # NOT adding the intermediary in but just using it's UFS
      Factory(:funding_flow, :from => @org1, :to => @org2, :project => @proj2,
        :budget => 1, :spend => 2)
      Factory(:funding_flow, :from => @org2, :to => @org3, :project => @proj3,
        :budget => 50)
      @proj2.reload
      @proj3.reload
      ufs = @proj3.ultimate_funding_sources
      ufs_without_chains(ufs).should == [{:ufs => @org1, :fa => @org2, :budget => 1, :spend => 2}]
      # TEST that error was logged
    end

    it "returns real UFS if it's implementer of an activity of funded organization" do
      @proj21 = Factory(:project, :data_response => @response2, :currency => "USD")
      @proj22 = Factory(:project, :data_response => @response2, :currency => "USD")

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
      @proj1.reload
      @proj21.reload
      @proj22.reload
      @proj3.reload
      ufs = @proj3.ultimate_funding_sources
      #ufs_without_chains(ufs).should == [{:ufs => @org1, :fa => @org2, :budget => 30, :spend => 30}]
      ufs_pretty_should_equal(ufs,[{:ufs => @org1, :fa => @org2, :budget => 30, :spend => 30}])
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
      @proj2.reload
      @proj3.reload
      ufs = @proj3.ultimate_funding_sources
      ufs_without_chains(ufs).should == [{:ufs => @org2, :fa => @org3, :budget => 1, :spend => 2}]
    end

    it "walks up donor as usual if matching activity is found for it in donor data response" do
      # organization 2 is donor
      @org2.raw_type = "Donor"; @org2.save
      Factory(:funding_flow, :from => @org0, :to => @org2, :project => @proj2,
              :budget => 50, :spend => 50)
      activity = Factory(:activity, :project => @proj2, :provider => @org3,
                         :budget => 50, :data_response => @response2)

      # organization 3
      Factory(:funding_flow, :from => @org2, :to => @org3, :project => @proj3,
              :budget => 50, :spend => 50)
      @proj2.reload
      @proj3.reload
      ufs = @proj3.ultimate_funding_sources
      ufs_without_chains(ufs).should == [{:ufs => @org0, :fa => @org2, :budget => 50, :spend => 50}]
    end

    # bugfix spec
    it "doesn't duplicates organizations when same from-to flows reported" do
      # organization 2 is donor
      @org2.raw_type = "Donor"; @org2.save
      Factory(:funding_flow, :from => @org0, :to => @org2, :project => @proj2,
              :budget => 100, :spend => 100)
      activity = Factory(:activity, :project => @proj2, :provider => @org3,
                         :budget => 50, :data_response => @response2)

      # organization 3
      Factory(:funding_flow, :from => @org2, :to => @org3, :project => @proj3,
              :budget => 50, :spend => 50)
      Factory(:funding_flow, :from => @org2, :to => @org3, :project => @proj3,
              :budget => 50, :spend => 50)
      @proj2.reload
      @proj3.reload
      ufs = @proj3.ultimate_funding_sources
      ufs_without_chains(ufs).should == [{:ufs => @org0, :fa => @org2, :budget => 100, :spend => 100}]
    end

    it "gives donor as real UFS if no matching activity is found for it in donor data response" do
      # organization 2 is donor
      @org2.raw_type = "Donor"; @org2.save
      Factory(:funding_flow, :from => @org0, :to => @org2, :project => @proj2,
              :budget => 50, :spend => 50)

      # organization 3
      Factory(:funding_flow, :from => @org2, :to => @org3, :project => @proj3,
              :budget => 1, :spend => 2)
      @proj2.reload
      @proj3.reload
      ufs = @proj3.ultimate_funding_sources
      ufs_without_chains(ufs).should == [{:ufs => @org2, :fa => @org3, :budget => 1, :spend => 2}]
    end
  end

  def ufs_without_chains(ufs)
    ufs.each{|fs| fs.delete(:org_chain)}
  end

  def ufs_pretty_should_equal(ufs, target)
    ufs.each{|fs| fs.delete(:org_chain)}
    if ufs.size == 1 and ufs.size == target.size
      ufs = ufs.first; target = target.first
      # simple case, can do pretty compare

      ufs[:ufs].should == first[:ufs]
      ufs[:fa].should == first[:fa]
      ufs[:budget].should == first[:budget]
      ufs[:spend].should == first[:spend]
      # chain[:org_chain].should == target's after we add chains to test
    else
      ufs.should == target
    end

  end
end
