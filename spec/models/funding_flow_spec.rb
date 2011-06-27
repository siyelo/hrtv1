require File.dirname(__FILE__) + '/../spec_helper'

describe FundingFlow do
  describe "attributes" do
    it { should allow_mass_assignment_of(:organization_text) }
    it { should allow_mass_assignment_of(:project_id) }
    it { should allow_mass_assignment_of(:data_response_id) }
    it { should allow_mass_assignment_of(:from) }
    it { should allow_mass_assignment_of(:to) }
    it { should allow_mass_assignment_of(:self_provider_flag) }
    it { should allow_mass_assignment_of(:organization_id_from) }
    it { should allow_mass_assignment_of(:organization_id_to) }
    it { should allow_mass_assignment_of(:spend) }
    it { should allow_mass_assignment_of(:spend_q4_prev) }
    it { should allow_mass_assignment_of(:spend_q1) }
    it { should allow_mass_assignment_of(:spend_q2) }
    it { should allow_mass_assignment_of(:spend_q3) }
    it { should allow_mass_assignment_of(:spend_q4) }
    it { should allow_mass_assignment_of(:budget_q4_prev) }
    it { should allow_mass_assignment_of(:budget_q1) }
    it { should allow_mass_assignment_of(:budget_q2) }
    it { should allow_mass_assignment_of(:budget_q3) }
    it { should allow_mass_assignment_of(:budget_q4) }
  end

  describe "associations" do
    it { should belong_to :from }
    it { should belong_to :to }
    it { should belong_to :project }
    it { should belong_to :data_response }
  end

  describe "validations" do
    subject { Factory(:funding_flow) }
    it { should be_valid }
    it { should validate_presence_of(:data_response_id) }
    ### these break with  shoulda 2.11.3 "translation missing"
    #it { should validate_presence_of(:organization_id_to) }
    #it { should validate_presence_of(:organization_id_from) }
    # and this breaks too
    #it { should validate_numericality_of(:organization_id_from) }
    it { should validate_numericality_of(:project_from_id) }
    
  end

  describe "more validations" do
    it "should validate the spend fields" do
      @activity = Factory.build(:funding_flow, :spend => 'abcd')
      @activity.save.should be_false
    end
    it "should validate the budget fields" do
      @activity = Factory.build(:funding_flow, :budget => 'abcd')
      @activity.save.should be_false
    end
  end

  describe "takes amounts from quarterlys if no budget/spend present" do
    it "if spend is nil it should use the amounts int eh quarterlys" do
      @activity = Factory(:funding_flow, :spend => nil, :spend_q1 => 2, :spend_q2 => 3, :spend_q4 => 4, :spend_q3 => 1)
      @activity.spend.should == 10
      @activity.save.should be_true
    end
    
    it "if budget is nil it should use the amounts int eh quarterlys" do
      @activity = Factory(:funding_flow, :budget => nil, :budget_q1 => 2, :budget_q2 => 3, :budget_q4 => 4, :budget_q3 => 1)
      @activity.budget.should == 10
      @activity.save.should be_true
    end
    
    it "if the budget is not nil it will use the budget amount" do 
      @activity = Factory(:funding_flow, :budget => 99, :budget_q1 => 2, :budget_q2 => 3, :budget_q4 => 4, :budget_q3 => 1)
      @activity.budget.should == 99
      @activity.save.should be_true
    end
    
    it "if the spend is not nil it will use the budget amount" do 
      @activity = Factory(:funding_flow, :spend => 99, :spend_q1 => 2, :spend_q2 => 3, :spend_q4 => 4, :spend_q3 => 1)
      @activity.spend.should == 99
      @activity.save.should be_true
    end
  end

  describe "counter cache" do
    context "comments cache" do
      before :each do
        @commentable = Factory.create(:funding_flow)
      end

      it_should_behave_like "comments_cacher"
    end
  end

  describe "currency" do
    it "returns project currency" do
      project = Factory.create(:project, :currency => "RWF")
      funding_flow = Factory.create(:funding_flow, :project => project)
      funding_flow.currency.should == "RWF"
    end
  end

  describe "#name" do
    it "returns from and to organizations in the name" do
      from = Factory.create(:organization, :name => 'Organization 1')
      to   = Factory.create(:organization, :name => 'Organization 2')
      funding_flow = Factory.create(:funding_flow, :from => from, :to => to)
      funding_flow.name.should == "From: #{from} - To: #{to}"
    end
  end

# TODO reenable at some point, method covered by other tests
#  describe "#funding_chains" do
#    before :each do
#      ufs_test_setup
#    end
#
#    #it "returns no UFS if project has no funder" do
#    # is an invalid test case since now flow will exist.
#
#    it "returns self for self funded" do
#      flow = Factory(:funding_flow, :from => @org1, :to => @org1, :project => @proj1,
#        :budget => 10, :spend => 20)
#      flow.funding_chains.should == {:org_chain => [@org1, @org1], :ufs => @org1,
#        :fa => @org1, :budget => bd(10), :spend => bd(20)}
#    end
#
#    ["Donor",  "Multilateral", "Bilateral"].each do |donor_type|
#      it "returns self for #{donor_type} funded" do
#        @org2.raw_type = donor_type; @org2.save
#        flow = Factory(:funding_flow, :from => @org2, :to => @org1, :project => @proj1,
#          :budget => 10, :spend => 20)
#        chain = flow.funding_chains
#        chain[:org_chain].should == [@org2, @org1]
#        chain[:ufs].should == @org2
#        chain[:fa].should == @org1 #financing agent is self
#        chain[:budget].should == bd(10)
#        chain[:spend].should == bd(20)
#      end
#    end
#
#    it "returns funder as the UFS if has one, non-self funder with no data response" do
#      flow = Factory(:funding_flow, :from => @org_with_no_data_response, :to => @org1,
#        :project => @proj1, :budget => 1, :spend => 2)
#      chain = flow.funding_chains
#      chain.should_not be_empty
#      chain[:org_chain].should == [@org_with_no_data_response, @org1]
#      chain[:ufs].should == @org_with_no_data_response
#      chain[:fa].should == @org1 #financing agent is self
#      chain[:budget].should == bd(1)
#      chain[:spend].should == bd(2)
#    end
#
#    it "returns funder as the UFS if has one, non-self funder with emtpy data response" do
#      flow = Factory(:funding_flow, :from => @org_with_empty_data_response, :to => @org1,
#        :project => @proj1, :budget => 1, :spend => 2)
#      chain = flow.funding_chains
#      chain.should_not be_empty
#      chain[:org_chain].should == [@org_with_empty_data_response, @org1]
#      chain[:ufs].should == @org_with_empty_data_response
#      chain[:fa].should == @org1 #financing agent is self
#      chain[:budget].should == bd(1)
#      chain[:spend].should == bd(2)
#    end
#
#    it "returns n-1 (upstream) funder as the UFS if upstream has one funder with empty dr" do
#      proj_funded_by(@proj1, @org_with_empty_data_response, 1, 2)
#      proj_funded_by(@proj2, @org1)
#      ufs = @proj2.ultimate_funding_sources
#      ufs.should == [{:ufs => @org_with_empty_data_response, :fa => @org1,
#                      :budget => 1, :spend => 2}]
#    end
#
#  end
#
#  describe "#adjust_to_total" do
#    before :each do
#      @flow = Factory(:funding_flow)
#      @target = 10
#      @amount_key = :budget
#    end
#
#    it "does nothing when total already ok" do
#      collection = [{:budget => 10}]
#      @flow.adjust_to_total(collection, @target, @amount_key).should == collection
#    end
#
#    it "does nothing when total already ok with multiple items" do
#      collection = [{:budget => 6}, {:budget => 4}]
#      @flow.adjust_to_total(collection, @target, @amount_key).should == collection
#    end
#
#    it "adjusts to target amount with one unmatching item" do
#      collection = [{:budget => 100}]
#      @flow.adjust_to_total(collection, @target, @amount_key).should == [{:budget => 10}]
#    end
#
#    it "adjusts to target amount with several unmatching integer items" do
#      collection = [{:budget => 10}, {:budget => 20}, {:budget => 30}]
#      item_total = 60
#      @flow.adjust_to_total(collection, @target, @amount_key).should ==
#        [{:budget => 10/item_total * @target},
#          {:budget => 20/item_total * @target},
#          {:budget => 30/item_total * @target}]
#    end
#
#    it "adjusts to target amount with several unmatching float items" do
#      collection = [{:budget => 10.to_f}, {:budget => 20.to_f}, {:budget => 30.to_f}]
#      item_total = 60.to_f
#      @flow.adjust_to_total(collection, @target, @amount_key).should ==
#        [{:budget => 10.to_f/item_total * @target},
#          {:budget => 20.to_f/item_total * @target},
#          {:budget => 30.to_f/item_total * @target}]
#    end
#  end
#
#  describe "#to_provider_totals" do
#    before :each do
#      ufs_test_setup
#      @flow = Factory(:funding_flow, :from => @org2, :to => @org1, :project => @proj12,
#        :budget => 10, :spend => 20)
#      @activity = Factory(:activity, :project => @proj12, :provider => @org1,
#                :data_response => @proj12.data_response, :budget => 5, :spend => 10)
#      @proj12.reload
#    end
#
#    it "finds the activities whose providers match who this fflow goes to" do
#      totals = @flow.to_provider_totals([@proj12])
#      totals.should have(1).item
#      totals[0][:budget].should == 5
#      totals[0][:spend].should == 10
#      totals[0][:p].should == @proj12
#    end
#
#    it "finds multiple activities whose providers match who this fflow goes to" do
#      activity = Factory(:activity, :project => @proj11, :provider => @org1,
#                :data_response => @proj11.data_response, :budget => 5, :spend => 10)
#      @proj11.reload
#      totals = @flow.to_provider_totals([@proj11, @proj12])
#      totals.should have(2).items
#      totals[0][:budget].should == 5
#      totals[0][:spend].should == 10
#      totals[0][:p].should == @proj11
#      totals[1][:budget].should == 5
#      totals[1][:spend].should == 10
#      totals[1][:p].should == @proj12
#    end
#  end


end

# == Schema Information
#
# Table name: funding_flows
#
#  id                   :integer         primary key
#  organization_id_from :integer
#  organization_id_to   :integer
#  project_id           :integer
#  created_at           :timestamp
#  updated_at           :timestamp
#  budget               :decimal(, )
#  spend_q1             :decimal(, )
#  spend_q2             :decimal(, )
#  spend_q3             :decimal(, )
#  spend_q4             :decimal(, )
#  organization_text    :text
#  self_provider_flag   :integer         default(0)
#  spend                :decimal(, )
#  spend_q4_prev        :decimal(, )
#  data_response_id     :integer
#  budget_q1            :decimal(, )
#  budget_q2            :decimal(, )
#  budget_q3            :decimal(, )
#  budget_q4            :decimal(, )
#  budget_q4_prev       :decimal(, )
#  comments_count       :integer         default(0)
#

