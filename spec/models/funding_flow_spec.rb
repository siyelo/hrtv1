require File.dirname(__FILE__) + '/../spec_helper'

describe FundingFlow do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:organization_text) }
    it { should allow_mass_assignment_of(:project_id) }
    it { should allow_mass_assignment_of(:data_response_id) }
    it { should allow_mass_assignment_of(:from) }
    it { should allow_mass_assignment_of(:to) }
    it { should allow_mass_assignment_of(:self_provider_flag) }
    it { should allow_mass_assignment_of(:organization_id_from) }
    it { should allow_mass_assignment_of(:organization_id_to) }
    it { should allow_mass_assignment_of(:spend) }
  end

  describe "Associations" do
    it { should belong_to :from }
    it { should belong_to :to }
    it { should belong_to :project }
    it { should belong_to :data_response }
  end

  describe "Validations" do
    it { should validate_presence_of(:data_response_id) }
    ### these break with  shoulda 2.11.3 "translation missing"
    #it { should validate_presence_of(:organization_id_to) }
    #it { should validate_presence_of(:organization_id_from) }
    # and this breaks too
    #it { should validate_numericality_of(:organization_id_from) }
    it { should validate_numericality_of(:project_from_id) }
    it { should validate_numericality_of(:budget) }
    it { should validate_numericality_of(:spend) }
  end

  describe "more validations" do
    before :each do
      basic_setup_project
    end

    it "should validate the spend fields" do
      @funding_flow = Factory.build(:funding_flow, :data_response => @response,
                                    :project => @project, :spend => 'abcd',
                                    :from => @organization, :to => @organization)
      @funding_flow.save.should be_false
    end

    it "should validate the budget fields" do
      @funding_flow = Factory.build(:funding_flow, :data_response => @response,
                                    :project => @project, :budget => 'abcd',
                                    :from => @organization, :to => @organization)
      @funding_flow.save.should be_false
    end
  end

  describe "currency" do
    it "returns project currency" do
      basic_setup_response
      @project     = Factory.create(:project, :data_response => @response, :currency => "RWF")
      funding_flow = Factory.build(:funding_flow, :data_response => @response,
                                    :project => @project,
                                    :from => @organization, :to => @organization)
      funding_flow.currency.should == "RWF"
    end
  end

  describe "#name" do
    it "returns from and to organizations in the name" do
      basic_setup_project
      from = Factory.create(:organization, :name => 'Organization 1')
      to   = Factory.create(:organization, :name => 'Organization 2')
      funding_flow = Factory.create(:funding_flow, :data_response => @response,
                                    :project => @project,
                                    :from => from, :to => to)

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

