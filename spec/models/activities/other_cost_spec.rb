require File.dirname(__FILE__) + '/../../spec_helper'

describe OtherCost do
  describe "associations" do
    it { should belong_to :provider }
    it { should belong_to :data_response }
    it { should belong_to :project }
    it { should have_and_belong_to_many :locations }
    it { should have_and_belong_to_many :organizations }
    it { should have_and_belong_to_many :beneficiaries }
    it { should have_many :sub_implementers }
    it { should have_many :codes }
    it { should have_many :code_assignments }
    it { should have_many :coding_budget }
    it { should have_many :coding_budget_cost_categorization }
    it { should have_many :coding_budget_district }
    it { should have_many :coding_spend }
    it { should have_many :coding_spend_cost_categorization }
    it { should have_many :coding_spend_district }
  end

  describe "attributes" do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:description) }
    it { should allow_mass_assignment_of(:start_date) }
    it { should allow_mass_assignment_of(:end_date) }
    it { should allow_mass_assignment_of(:project_id) }
    it { should allow_mass_assignment_of(:budget) }
    it { should allow_mass_assignment_of(:spend) }
    it { should allow_mass_assignment_of(:budget_q4_prev) }
    it { should allow_mass_assignment_of(:budget_q1) }
    it { should allow_mass_assignment_of(:budget_q2) }
    it { should allow_mass_assignment_of(:budget_q3) }
    it { should allow_mass_assignment_of(:budget_q4) }
    it { should allow_mass_assignment_of(:spend_q4_prev) }
    it { should allow_mass_assignment_of(:spend_q1) }
    it { should allow_mass_assignment_of(:spend_q2) }
    it { should allow_mass_assignment_of(:spend_q3) }
    it { should allow_mass_assignment_of(:spend_q4) }
    it { should allow_mass_assignment_of(:location_ids) }
    it { should allow_mass_assignment_of(:beneficiary_ids) }
    it { should allow_mass_assignment_of(:provider_id) }
    it { should allow_mass_assignment_of(:text_for_provider) }
    it { should allow_mass_assignment_of(:text_for_beneficiaries) }
    it { should allow_mass_assignment_of(:text_for_targets) }
    it { should allow_mass_assignment_of(:approved) }
    it { should allow_mass_assignment_of(:organization_ids) }
  end
  

  describe "classified?" do
    before :each do
      @request  = Factory(:data_request, :title => 'Data Request 1')
      @response = Factory(:data_response, :data_request => @request)
      @project = Factory(:project, :data_response => @response)
      @activity = Factory(:other_cost)
    end

    it "is classified? when both budget and spend are classified with factories" do
      classify_the_other_cost # has side effects- overrides @activity in before :each
      @activity.coding_budget_classified?.should == true
      @activity.coding_budget_cc_classified?.should == true
      @activity.coding_budget_district_classified?.should == true
      @activity.service_level_budget_classified?.should == true
      @activity.budget_classified?.should == true
      @activity.coding_spend_classified?.should == true
      @activity.coding_spend_cc_classified?.should == true
      @activity.coding_spend_district_classified?.should == true
      @activity.service_level_spend_classified?.should == true
      @activity.spend_classified?.should == true
      @activity.classified?.should be_true
    end

    it "is classified? when both budget and spend are classified" do
      @activity.stub(:budget_classified?) { true }
      @activity.stub(:spend_classified?) { true }
      @activity.classified?.should be_true
    end

    def currency
      project ? project.currency : data_response.currency
    end

    describe "currency" do
      it "returns data response currency if other cost without a project" do
        o = Factory(:organization, :currency => 'EUR')
        dr = Factory(:data_response, :organization => o)
        oc = Factory(:other_cost, :project => nil, :data_response => dr)
        oc.currency.should.eql? 'EUR'
      end

      it "returns project currency if other cost has a project" do
        pr = Factory(:project, :currency => 'USD')
        oc = Factory(:other_cost, :project => pr)
        oc.currency.should.eql? 'USD'
      end
    end
  end
end
