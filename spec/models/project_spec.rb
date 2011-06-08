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
    it { should have_many(:comments) }
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
    it { should allow_mass_assignment_of(:in_flows_attributes) }
    it { should allow_mass_assignment_of(:budget2) }
    it { should allow_mass_assignment_of(:budget3) }
    it { should allow_mass_assignment_of(:budget4) }
    it { should allow_mass_assignment_of(:budget5) }
    it { should allow_mass_assignment_of(:budget2) }
    it { should allow_mass_assignment_of(:budget3) }
    it { should allow_mass_assignment_of(:budget4) }
    it { should allow_mass_assignment_of(:budget5) }
    it { should allow_mass_assignment_of(:budget_q1) }
    it { should allow_mass_assignment_of(:budget_q2) }
    it { should allow_mass_assignment_of(:budget_q3) }
    it { should allow_mass_assignment_of(:budget_q4) }
    it { should allow_mass_assignment_of(:spend_q1) }
    it { should allow_mass_assignment_of(:spend_q2) }
    it { should allow_mass_assignment_of(:spend_q3) }
    it { should allow_mass_assignment_of(:spend_q4) }
    it { should allow_mass_assignment_of(:spend_q4_prev) }
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
    it { should allow_value('12,323.32').for(:spend) }
    it { should allow_value(123.45).for(:entire_budget) }
    it { should allow_value('2010-12-01').for(:start_date) }
    it { should allow_value('2010-12-01').for(:end_date) }
    it { should_not allow_value('abcd').for(:budget) }
    it { should_not allow_value('abcd').for(:budget_q1) }
    it { should_not allow_value('abcd').for(:budget_q2) }
    it { should_not allow_value('abcd').for(:budget_q3) }
    it { should_not allow_value('abcd').for(:budget_q4) }
    it { should_not allow_value('abcd').for(:budget_q4_prev) }
    it { should_not allow_value('abcd').for(:spend) }
    it { should_not allow_value('abcd').for(:spend_q1) }
    it { should_not allow_value('abcd').for(:spend_q2) }
    it { should_not allow_value('abcd').for(:spend_q3) }
    it { should_not allow_value('abcd').for(:spend_q4) }
    it { should_not allow_value('abcd').for(:spend_q4_prev) }
    it { should_not allow_value('abcd').for(:budget2) }
    it { should_not allow_value('abcd').for(:budget3) }
    it { should_not allow_value('abcd').for(:budget4) }
    it { should_not allow_value('abcd').for(:budget5) }

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


  describe "cleans currency formats" do
    FIELDS = [:spend, :spend_q1, :spend_q2, :spend_q3, :spend_q4, :budget, :entire_budget]
    TESTS = [
              ["10,783.32",     "10783.32",  "clean commas"],
              ["$10,783.32",    "10783.32",   "ignore currency symbols and commas"],
              ["$10783.32",     "10783.32",   "ignore currency symbols"],
              ["10783,32",      "1078332.0",  "ingore commas as decimal separator"],
              ["10.783,32",     "10.78332",   "ignore decimals as thousands separators"],
              ["21.100.783,32", "21.1",       "ignore multiple decimals as thousands separators"]
            ]
    FIELDS.each do |field|
      context "for field: #{field}" do
        before :each do
          @project = Factory(:project)
        end

        TESTS.each do |test|
          it "should #{test[2]}" do
            @project.send(field.to_s + "=", test[0])
            @project.save
            @project.send(field).to_s.should == test[1]
          end
        end
      end
    end
  end

  context "Amount validations" do
    it "should return true if budget is equal to that of the quarterlys" do
      @project = Factory(:project, :budget => "140",
                         :budget_q1 => "20", :budget_q2 => "30",
                         :budget_q3 => "40", :budget_q4 => "50")
      @project.total_matches_quarters?(:budget).should be_true
    end

     it "should return true if budget is equal to that of the quarterlys" do
       @project = Factory(:project, :spend => "140",
                          :spend_q1 => "20", :spend_q2 => "30",
                          :spend_q3 => "40", :spend_q4 => "50")
       @project.total_matches_quarters?(:spend).should be_true
     end

      it "should return true if spend is nil and quarterlys are too" do
        @project = Factory(:project, :spend => nil,
                            :spend_q1 => nil, :spend_q2 => nil,
                            :spend_q3 => nil, :spend_q4 => nil)
        @project.total_matches_quarters?(:spend).should be_true
      end

      it "should return false if spend is nil and quarterlys are too" do
        @project = Factory(:project, :spend => nil,
                            :spend_q1 => nil, :spend_q2 => nil,
                            :spend_q3 => nil, :spend_q4 => nil)
        @project.total_matches_quarters?(:spend).should be_true
      end
  end

  context "Submit page: " do
    before(:each) do
      @our_org       = Factory(:organization)
      @response      = Factory(:data_response,
                               :organization => @our_org)
      @other_org     = Factory(:organization)
      @project       = Factory(:project,
                               :data_response => @response )
    end

    it "returns true if a project funders has an organization" do
      flow      = Factory(:funding_flow,
                          :from          => @other_org,
                          :to            => @our_org,
                          :project       => @project,
                          :data_response => @project.data_response)
      @project.reload
      @project.funding_sources_have_organizations?.should be_true
    end

    # this should be deprecated since org from is required from now on
    it "returns false if a project funders has an organization" do
      flow      = Factory(:funding_flow,
                          :from          => @other_org,
                          :to            => @our_org,
                          :project       => @project,
                          :data_response => @project.data_response)
      @project.reload
      @project.in_flows.each do |in_flow|
        in_flow.organization_id_from = nil
        in_flow.save(false)
      end
      @project.reload
      @project.funding_sources_have_organizations?.should be_false
    end

    it "checks whether a project has an activity" do
      @activity = Factory(:activity, :project => @project)
      @project.has_activities?.should == true
    end

    it "checks whether a project has an activity when it does not" do
      @project.has_activities?.should be_false
    end

    it "checks whether a project has an other cost" do
      @activity = Factory(:other_cost, :project => @project)
      @project.has_other_costs?.should == true
    end

    it "checks whether a project has an other cost when it does not" do
      @project.has_other_costs?.should be_false
    end

    it "checks whether a project has an activity when an other cost is present" do
      @activity = Factory(:other_cost, :project => @project)
      @project.has_activities?.should be_false
    end

    it "checks whether a project has an other cost when an activity is present" do
      @activity = Factory(:activity, :project => @project)
      @project.has_other_costs?.should be_false
    end
  end

  context "Funding flows: " do
    before(:each) do
      @our_org       = Factory(:organization)
      @response      = Factory(:data_response,
                               :organization => @our_org)
      @other_org     = Factory(:organization)
      @project       = Factory(:project,
                               :data_response => @response )
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

      @response      = Factory(:data_response, :currency => 'RWF')
      @project       = Factory(:project,
                                :data_response => @response,
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

  describe "project spend check" do
    before :each do
      @project = Factory(:complete_project, :spend => 20)
      funder = @project.in_flows.first
      funder.spend = 20
      funder.save
      @project.reload
    end

    it "succeeds if spend is entered" do
      @project.spend_entered?.should == true

    end

    it "succeeds if spend not entered but a quarter spend is" do
      @project.spend = nil
      @project.spend_q1 = 10
      @project.save
      @project.spend_entered?.should == true
    end

    it "fails if spend is not entered and no quarter spends are" do
      @project.spend = nil
      @project.save
      @project.spend_entered?.should be_false
    end
  end

  describe "project budget" do
    before :each do
      @project = Factory(:project, :budget => 20)
    end

    it "succeeds if entered" do
      @project.budget_entered?.should == true
    end

    it "succeeds if not entered but a quarter budget is" do
      @project.budget = nil
      @project.budget_q1 = 10
      @project.save
      @project.budget_entered?.should == true
    end

    it "fails if not entered and no quarter budgets are" do
      @project.budget = nil
      @project.save
      @project.budget_entered?.should be_false
    end
  end

  describe "linking to funding source project" do
    before :each do
      @data_request = Factory(:data_request)
      @data_request1 = Factory(:data_request)
      @organization = Factory(:organization)
      @organization1 = Factory(:organization)
      @response      = Factory(:data_response, :data_request => @data_request,
                               :organization => @organization)
      @response1 = Factory(:data_response, :data_request => @data_request1,
                                :organization => @organization1)
      @project = Factory(:project, :data_response => @response)
    end

    it "returns false if a project is not linked to a parent project" do
      @project.linked?.should be_false
    end

    it "returns true if a project is linked to a parent project" do
      @funding_flow = Factory(:funding_flow, :from => @organization1, :to => @organization, :project => @project,
                              :data_response => @response, :project_from_id => @project.id)
      @project.reload
      @project.linked?.should == true
    end

    it "returns true if a project is not linked to a parent project but has been set to project 'project missing/unknown'" do
      @funding_flow = Factory(:funding_flow, :from => @organization1, :to => @organization,
        :project => @project, :data_response => @response, :project_from_id => 0)
      @project.reload
      @project.linked?.should == true
    end
  end
end
