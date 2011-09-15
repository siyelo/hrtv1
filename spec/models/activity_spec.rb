require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  describe "Associations" do
    it { should belong_to :provider }
    it { should belong_to :data_response }
    it { should belong_to :project }
    it { should have_and_belong_to_many :organizations }
    it { should have_and_belong_to_many :beneficiaries }
    it { should have_many(:implementer_splits).dependent(:destroy) }
    it { should have_many(:sub_activities).dependent(:destroy) } #TODO deprecate
    it { should have_many(:implementers) }
    it { should have_many(:sub_implementers) } #TODO deprecate
    it { should have_many(:codes) }
    it { should have_many(:purposes) }
    it { should have_many(:code_assignments).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:coding_budget).dependent(:destroy) }
    it { should have_many(:coding_budget_cost_categorization).dependent(:destroy) }
    it { should have_many(:coding_budget_district).dependent(:destroy) }
    it { should have_many(:coding_spend).dependent(:destroy) }
    it { should have_many(:coding_spend_cost_categorization).dependent(:destroy) }
    it { should have_many(:coding_spend_district).dependent(:destroy) }
    it { should have_many(:targets).dependent(:destroy) }
    it { should have_many(:outputs).dependent(:destroy) }
  end

  describe "Attributes" do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:description) }
    it { should allow_mass_assignment_of(:project_id) }
    it { should allow_mass_assignment_of(:budget) }
    it { should allow_mass_assignment_of(:spend) }
    it { should allow_mass_assignment_of(:beneficiary_ids) }
    it { should allow_mass_assignment_of(:provider_id) }
    it { should allow_mass_assignment_of(:text_for_provider) }
    it { should allow_mass_assignment_of(:text_for_beneficiaries) }
    it { should allow_mass_assignment_of(:approved) }
    it { should allow_mass_assignment_of(:implementer_splits_attributes) }
    it { should allow_mass_assignment_of(:implementer_splits_attributes) }
    it { should allow_mass_assignment_of(:organization_ids) }
    it { should allow_mass_assignment_of(:csv_project_name) }
    it { should allow_mass_assignment_of(:csv_provider) }
    it { should allow_mass_assignment_of(:csv_beneficiaries) }
    it { should allow_mass_assignment_of(:targets_attributes) }
    it { should allow_mass_assignment_of(:outputs_attributes) }
    it { should allow_mass_assignment_of(:am_approved_date) }
    it { should allow_mass_assignment_of(:planned_for_gor_q1) }
    it { should allow_mass_assignment_of(:planned_for_gor_q2) }
    it { should allow_mass_assignment_of(:planned_for_gor_q3) }
    it { should allow_mass_assignment_of(:planned_for_gor_q4) }
  end

  describe "Validations" do
    subject { basic_setup_activity; @activity }
    it { should validate_presence_of(:data_response_id) }
    it { should validate_presence_of(:project_id) }
    it { should ensure_length_of(:name) }
    it { should validate_presence_of(:description) }

    it "cannot be edited once approved" do
      subject.stub(:approved).and_return(true)
      subject.stub(:approved?).and_return(true)

      subject.name = "new activity name"
      subject.save.should == false
      subject.errors.on(:base).should include("Activity was approved by SysAdmin and cannot be changed")
    end

    it "cannot be approved if unclassified" do
      subject.stub(:classified?).and_return(false)

      subject.approved = true
      subject.save.should == false
      subject.errors.on(:base).should include("Cannot approve unclassified Activity")
    end
  end

  describe "update attributes" do
    context "when one sub_activity" do
      before :each do
        basic_setup_activity
        attributes = {"name"=>"dsf", "project_id"=>"#{@project.id}",
          "implementer_splits_attributes"=>
            {"0"=>{"spend"=>"10", "data_response_id"=>"#{@response.id}", "provider_mask"=>"#{@organization.id}",
            "budget"=>"20.0", "_destroy"=>""}
            }, "description"=>"adfasdf"}
        @activity.reload
        @activity.update_attributes(attributes).should be_true
      end

      it "should maintain the activites budget/spend cache when creating a new sub_activity" do
        @activity.implementer_splits.size.should == 1
        @activity.implementer_splits[0].implementer.should == @organization
        @activity.implementer_splits[0].spend.to_f.should == 10
        @activity.implementer_splits[0].budget.to_f.should == 20
        @activity.reload
        @activity.spend.to_f.should == 10
        @activity.budget.to_f.should == 20
      end

      it "should not call activity cache update more than once" do
        pending #tricky to count the number of method calls on the callback
      end
    end

    context "when two implementer_splits" do
      before :each do
        basic_setup_sub_activity
        @implementer2 = Factory :organization
        @sub_activity2 = Factory(:sub_activity, :data_response => @response,
                                 :activity => @activity, :provider => @implementer2)

        attributes = {"name"=>"dsf",  "project_id"=>"#{@project.id}",
          "implementer_splits_attributes"=>
            {"0"=>
              {"spend"=>"10", "id"=>"#{@sub_activity.id}", "data_response_id"=>"#{@response.id}", "provider_mask"=>"#{@organization.id}", "budget"=>"20.0"},
            "1"=>
              {"spend"=>"20", "id"=>"#{@sub_activity2.id}", "data_response_id"=>"#{@response.id}", "provider_mask"=>"#{@implementer2.id}", "budget"=>"40.0"}
            }, "description"=>"adfasdf"}
        @activity.reload
        @activity.update_attributes(attributes).should be_true
      end

      it "should maintain the activites budget/spend cache when creating a new sub_activity" do
        @activity.implementer_splits.size.should == 2
        @activity.implementer_splits[0].implementer.should == @organization
        @activity.implementer_splits[0].spend.to_f.should == 10
        @activity.implementer_splits[0].budget.to_f.should == 20
        @activity.implementer_splits[1].implementer.should == @implementer2
        @activity.implementer_splits[1].spend.to_f.should == 20
        @activity.implementer_splits[1].budget.to_f.should == 40
        @activity.reload
        @activity.spend.to_f.should == 30
        @activity.budget.to_f.should == 60
      end

      it "should not call activity cache update more than once" do
        pending #tricky to count the number of method calls on the callback
      end
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

  describe "gets budget and spend from sub activities" do
    before :each do
      basic_setup_activity
      @sa = Factory(:sub_activity, :activity => @activity, :data_response => @response,
              :budget => 25, :spend => 10)
      @activity.reload; @activity.save;
    end

    it "activity.budget should be the total of sub activities(1)" do
      @activity.budget.to_f.should == 25
    end

    it "activity.spend should be the total of sub activities(1)" do
      @activity.spend.to_f.should == 10
    end

    it "refreshes the amount if the amount of the sub-activity changes" do
      @sa.spend = 13; @sa.budget = 29; @sa.save!; @activity.reload; @activity.save;
      @activity.spend.to_f.should == 13
      @activity.budget.to_f.should == 29
    end

    describe "works with more than one sub activity" do
      before :each do
        @sa1 = Factory(:sub_activity, :activity => @activity, :data_response => @response,
                :budget => 125, :spend => 100)
        @activity.reload; @activity.save;
      end

      it "activity.budget should be the total of sub activities(2)" do
        @activity.budget.to_f.should == 150
      end

      it "activity.spend should be the total of sub activities(2)" do
        @activity.spend.to_f.should == 110
      end

      it "refreshes the amount if the amount of the sub-activity changes" do
        @sa.spend = 20; @sa.budget = 35; @sa.save!; @activity.reload; @activity.save;
        @activity.spend.to_f.should == 120
        @activity.budget.to_f.should == 160
      end
    end

    it "should not allow you to set the activities budget directly" do
      expect { budget }.should raise_error
    end

    it "should not allow you to set the activities spend directly" do
      expect { spend }.should raise_error
    end
  end

  describe "can show who we provided money to (providers)" do
    context "on a single project" do
      it "should have at least 1 provider" do
        basic_setup_project
        our_org   = Factory(:organization)
        other_org = Factory(:organization)
        flow      = Factory(:funding_flow, :from => our_org, :project => @project)
        activity  = Factory(:activity, :data_response => @response, :project => @project,
                      :provider => other_org )
        activity.provider.should == other_org # duh
      end
    end
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
        @activity.implementer_splits.reload
        @activity.amount_for_provider(@subact.provider, :budget).should == 10
      end
    end
  end

  describe "purposes" do
    it "should return only those codes designated as Purpose codes" do
      basic_setup_activity
      @purpose1    = Factory(:purpose, :short_display => 'purp1')
      @purpose2    = Factory(:mtef_code, :short_display => 'purp2')
      @input       = Factory(:input, :short_display => 'input')
      Factory(:coding_budget, :activity => @activity, :code => @purpose1,
        :amount => 5, :cached_amount => 5)
      Factory(:coding_budget, :activity => @activity, :code => @purpose2,
                 :amount => 15, :cached_amount => 15)
      Factory(:coding_budget_cost_categorization, :activity => @activity, :code => @input,
        :amount => 5, :cached_amount => 5)
      @activity.purposes.should == [@purpose1, @purpose2]
    end
  end

  describe "#locations" do
    it "returns uniq locations only from district classifications" do
      basic_setup_activity
      location1 = Factory(:location)
      location2 = Factory(:location)
      location3 = Factory(:location)
      location4 = Factory(:location)
      Factory(:coding_budget_district, :activity => @activity, :code => location1)
      Factory(:coding_budget_district, :activity => @activity, :code => location2)
      Factory(:coding_spend_district, :activity => @activity, :code => location2)
      Factory(:coding_budget, :activity => @activity, :code => location3)
      Factory(:coding_spend, :activity => @activity, :code => location4)

      @activity.locations.length.should == 2
      @activity.locations.should include(location1)
      @activity.locations.should include(location2)
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

