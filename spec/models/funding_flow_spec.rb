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
    it { should validate_presence_of(:project) }
    it { should validate_presence_of(:data_response_id) }
    it { should validate_presence_of(:organization_id_to) }
    it { should validate_presence_of(:organization_id_from) }
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

