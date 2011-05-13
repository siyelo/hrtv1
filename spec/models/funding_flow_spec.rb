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
    #it { should validate_presence_of(:project) }
    #it { should validate_presence_of(:data_response_id) }
    #it { should validate_presence_of(:organization_id_to) }
    #it { should validate_presence_of(:organization_id_from) }
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

  describe "#funding_chains" do
    before :each do
      ufs_test_setup
    end

    #it "returns no UFS if project has no funder" do
    # is an invalid test case since now flow will exist.

    it "returns self for self funded" do
      flow = Factory(:funding_flow, :from => @org1, :to => @org1, :project => @proj1,
        :budget => 10, :spend => 20)
      flow.funding_chains.should == {:org_chain => [@org1, @org1], :ufs => @org1,
        :fa => @org1, :budget => bd(10), :spend => bd(20)}
    end

    ["Donor",  "Multilateral", "Bilateral"].each do |donor_type|
      it "returns self for #{donor_type} funded" do
        @org2.raw_type = donor_type; @org2.save
        flow = Factory(:funding_flow, :from => @org2, :to => @org1, :project => @proj1,
          :budget => 10, :spend => 20)
        chain = flow.funding_chains
        chain[:org_chain].should == [@org2, @org1]
        chain[:ufs].should == @org2
        chain[:fa].should == @org1 #financing agent is self
        chain[:budget].should == bd(10)
        chain[:spend].should == bd(20)
      end
    end

    it "returns funder as the UFS if has one, non-self funder with no data response" do
      flow = Factory(:funding_flow, :from => @org_with_no_data_response, :to => @org1,
        :project => @proj1, :budget => 1, :spend => 2)
      chain = flow.funding_chains
      chain.should_not be_empty
      chain[:org_chain].should == [@org_with_no_data_response, @org1]
      chain[:ufs].should == @org_with_no_data_response
      chain[:fa].should == @org1 #financing agent is self
      chain[:budget].should == bd(1)
      chain[:spend].should == bd(2)
    end

    it "returns funder as the UFS if has one, non-self funder with emtpy data response" do
      flow = Factory(:funding_flow, :from => @org_with_empty_data_response, :to => @org1,
        :project => @proj1, :budget => 1, :spend => 2)
      chain = flow.funding_chains
      chain.should_not be_empty
      chain[:org_chain].should == [@org_with_empty_data_response, @org1]
      chain[:ufs].should == @org_with_empty_data_response
      chain[:fa].should == @org1 #financing agent is self
      chain[:budget].should == bd(1)
      chain[:spend].should == bd(2)
    end

    it "returns n-1 (upstream) funder as the UFS if upstream has one funder with empty dr" do
      proj_funded_by(@proj1, @org_with_empty_data_response, 1, 2)
      proj_funded_by(@proj2, @org1)
      ufs = @proj2.ultimate_funding_sources
      ufs.should == [{:ufs => @org_with_empty_data_response, :fa => @org1,
                      :budget => 1, :spend => 2}]
    end

  end

  describe "#adjust_to_total" do
    before :each do
      @flow = Factory(:funding_flow)
      @target = 10
      @amount_key = :budget
    end

    it "does nothing when total already ok" do
      collection = [{:budget => 10}]
      @flow.adjust_to_total(collection, @target, @amount_key).should == collection
    end

    it "does nothing when total already ok with multiple items" do
      collection = [{:budget => 6}, {:budget => 4}]
      @flow.adjust_to_total(collection, @target, @amount_key).should == collection
    end

    it "adjusts to target amount with one unmatching item" do
      collection = [{:budget => 100}]
      @flow.adjust_to_total(collection, @target, @amount_key).should == [{:budget => 10}]
    end

    it "adjusts to target amount with several unmatching integer items" do
      collection = [{:budget => 10}, {:budget => 20}, {:budget => 30}]
      item_total = 60
      @flow.adjust_to_total(collection, @target, @amount_key).should ==
        [{:budget => 10/item_total*@target},
          {:budget => 20/item_total*@target},
          {:budget => 30/item_total*@target}]
    end

    it "adjusts to target amount with several unmatching float items" do
      collection = [{:budget => 10.to_f}, {:budget => 20.to_f}, {:budget => 30.to_f}]
      item_total = 60.to_f
      @flow.adjust_to_total(collection, @target, @amount_key).should ==
        [{:budget => 10.to_f/item_total*@target},
          {:budget => 20.to_f/item_total*@target},
          {:budget => 30.to_f/item_total*@target}]
    end
  end

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

