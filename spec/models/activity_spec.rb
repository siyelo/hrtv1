require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  describe "Associations" do
    it { should belong_to :provider }
    it { should belong_to :data_response }
    it { should belong_to :project }
    it { should have_and_belong_to_many :locations }
    it { should have_and_belong_to_many :organizations }
    it { should have_and_belong_to_many :beneficiaries }
    it { should have_many :sub_activities }
    it { should have_many :sub_implementers }
    it { should have_many :funding_sources }
    it { should have_many :codes }
    it { should have_many :code_assignments }
    it { should have_many :comments }
    it { should have_many :coding_budget }
    it { should have_many :coding_budget_cost_categorization }
    it { should have_many :coding_budget_district }
    it { should have_many :coding_spend }
    it { should have_many :coding_spend_cost_categorization }
    it { should have_many :coding_spend_district }
    it { should have_many :outputs }
  end

  describe "Attributes" do
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
    it { should allow_mass_assignment_of(:approved) }
    it { should allow_mass_assignment_of(:sub_activities_attributes) }
    it { should allow_mass_assignment_of(:organization_ids) }
    it { should allow_mass_assignment_of(:funding_sources_attributes) }
    it { should allow_mass_assignment_of(:csv_project_name) }
    it { should allow_mass_assignment_of(:csv_provider) }
    it { should allow_mass_assignment_of(:csv_districts) }
    it { should allow_mass_assignment_of(:csv_beneficiaries) }
  end

  describe "Validations" do
    subject { basic_setup_activity; @activity }
    it { should be_valid }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:data_response_id) }
    it { should validate_presence_of(:project_id) }
    it { should ensure_length_of(:name) }
    it { should validate_numericality_of(:budget) }
    it { should validate_numericality_of(:spend) }

    it "will return false if the activity start date is before the project start date" do
      basic_setup_response
      @project  = Factory(:project, :data_response => @response,
                         :start_date => '2011-01-01', :end_date => '2011-04-01')
      @activity = Factory.build(:activity, :data_response => @response, :project => @project,
                         :start_date => Date.parse("2010-01-01"), :end_date => Date.parse("2011-03-01"))
      @activity.should_not be_valid
    end

    it "will return false if the activity end date is after the project end date" do
      basic_setup_response
      @project  = Factory(:project, :data_response => @response,
                         :start_date => '2011-01-01', :end_date => '2011-04-01')
      @activity = Factory.build(:activity, :data_response => @response, :project => @project,
                         :start_date => Date.parse("2001-03-01"), :end_date => Date.parse("2011-08-01"))

      @activity.should_not be_valid
    end

    it "will return true if the activity start and end date are within the project start and end date" do
      basic_setup_response
      @project  = Factory(:project, :data_response => @response,
                         :start_date => '2011-01-01', :end_date => '2011-04-01')
      @activity = Factory.build(:activity, :data_response => @response, :project => @project,
                         :start_date => Date.parse("2011-02-01"), :end_date => Date.parse("2011-03-01"))

      @activity.should be_valid
    end
  end

  describe "download activity template" do
    it "returns the correct fields in the activity template" do
      basic_setup_response
      Date.stub!(:today).and_return(Date.parse("01-01-2009"))
      header_row = Activity.download_template(@response)
      header_row.should == "Project Name,Activity Name,Activity Description,Provider,Past Expenditure,Jul '08 - Sep '08 Spend,Oct '08 - Dec '08 Spend,Jan '09 - Mar '09 Spend,Apr '09 - Jun '09 Spend,Jul '09 - Sep '09 Spend,Current Budget,Jul '09 - Sep '09 Budget,Oct '09 - Dec '09 Budget,Jan '10 - Mar '10 Budget,Apr '10 - Jun '10 Budget,Jul '10 - Sep '10 Budget,Districts,Beneficiaries,Beneficiary details / Other beneficiaries,Outputs / Targets,Start Date,End Date,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Id\n"
    end
  end

  describe "organization_name" do
    it "returns organization nane" do
      @organization = Factory(:organization, :name => "Organization1")
      @request      = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
      @project      = Factory(:project, :data_response => @response)
      @activity     = Factory(:activity, :data_response => @response, :project => @project)

      @activity.organization_name.should == "Organization1"
    end
  end

  describe "can show who we provided money to (providers)" do
    context "on a single project" do
      it "should have at least 1 provider" do
        basic_setup_project
        our_org   = Factory(:organization)
        other_org = Factory(:organization)
        flow      = Factory(:funding_flow, :data_response => @response,
                            :from => our_org, :to => other_org, :project => @project)
        activity  = Factory(:activity, :data_response => @response,
                            :project => @project, :provider => other_org )
        activity.provider.should == other_org # duh
      end
    end
  end

  it "cannot be edited once approved" do
    basic_setup_activity
    @activity.approved.should == nil
    @activity.approved = true
    @activity.save!
    @activity.spend = 2000
    @activity.save.should == false
  end

  describe "counter cache" do
    context "comments cache" do
      before :each do
        basic_setup_activity
        @commentable = @activity
      end

      it_should_behave_like "comments_cacher"
    end

    it "caches sub activities count" do
      basic_setup_activity
      @activity.sub_activities_count.should == 0
      Factory(:sub_activity, :data_response => @response,
              :provider => @organization, :activity => @activity)
      @activity.reload.sub_activities_count.should == 1
    end
  end

  describe "deep cloning" do
    before :each do
      basic_setup_activity
      @original = @activity #for shared examples
    end

    it "should clone associated code assignments" do
      @ca = Factory(:code_assignment, :activity => @activity)
      save_and_deep_clone
      @clone.code_assignments.count.should == 1
      @clone.code_assignments[0].code.should == @ca.code
      @clone.code_assignments[0].amount.should == @ca.amount
      @clone.code_assignments[0].activity.should_not == @activity
      @clone.code_assignments[0].activity.should == @clone
    end

    it "should clone organizations" do
      @orgs = [Factory(:organization)]
      @activity.organizations << @orgs
      save_and_deep_clone
      @clone.organizations.should == @orgs
    end

    it "should clone beneficiaries" do
      @benefs = [Factory(:beneficiary)]
      @activity.beneficiaries << @benefs
      save_and_deep_clone
      @clone.beneficiaries.should == @benefs
    end

    it_should_behave_like "location cloner"
  end

  describe "CSV dates" do
    it "changes the date format from 12/12/2012 to 12-12-2012" do
      new_date = Activity.flexible_date_parse('12/12/2012')
      new_date.should.eql? Date.parse('12-12-2012')
    end

    it "changes the date format from 2012/03/30 to 30-03-2012" do
      new_date = Activity.flexible_date_parse('2012/03/30')
      new_date.should.eql? Date.parse('30-03-2012')
    end
  end

  describe "#amount_for_provider" do
    before :each do
      basic_setup_activity
    end

    context "normal activity" do
      it "should returns full amount for org1 when it is implementer" do
        @activity.amount_for_provider(@activity.provider, :budget).should == @activity.budget
      end

      it "should returns 0 when given org is not implementer" do
        @activity.amount_for_provider(Factory(:organization), :budget).should == 0
      end
    end

    context "sub activities" do
      it "looks for amount in sub-activity" do
        @subact = Factory(:sub_activity, :data_response => @response,
                          :activity => @activity, :budget => 10)
        @activity.sub_activities.reload
        @activity.amount_for_provider(@subact.provider, :budget).should == 10
      end
    end
  end
end


# == Schema Information
#
# Table name: activities
#
#  id                                    :integer         not null, primary key
#  name                                  :string(255)
#  created_at                            :datetime
#  updated_at                            :datetime
#  provider_id                           :integer
#  description                           :text
#  type                                  :string(255)
#  budget                                :decimal(, )
#  spend_q1                              :decimal(, )
#  spend_q2                              :decimal(, )
#  spend_q3                              :decimal(, )
#  spend_q4                              :decimal(, )
#  start_date                            :date
#  end_date                              :date
#  spend                                 :decimal(, )
#  text_for_provider                     :text
#  text_for_targets                      :text
#  text_for_beneficiaries                :text
#  spend_q4_prev                         :decimal(, )
#  data_response_id                      :integer
#  activity_id                           :integer
#  approved                              :boolean
#  CodingBudget_amount                   :decimal(, )     default(0.0)
#  CodingBudgetCostCategorization_amount :decimal(, )     default(0.0)
#  CodingBudgetDistrict_amount           :decimal(, )     default(0.0)
#  CodingSpend_amount                    :decimal(, )     default(0.0)
#  CodingSpendCostCategorization_amount  :decimal(, )     default(0.0)
#  CodingSpendDistrict_amount            :decimal(, )     default(0.0)
#  budget_q1                             :decimal(, )
#  budget_q2                             :decimal(, )
#  budget_q3                             :decimal(, )
#  budget_q4                             :decimal(, )
#  budget_q4_prev                        :decimal(, )
#  comments_count                        :integer         default(0)
#  sub_activities_count                  :integer         default(0)
#  spend_in_usd                          :decimal(, )     default(0.0)
#  budget_in_usd                         :decimal(, )     default(0.0)
#

