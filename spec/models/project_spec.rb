require File.dirname(__FILE__) + '/../spec_helper'
require 'set'

describe Project do
  describe "Associations" do
    it { should belong_to(:data_response) }
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

  describe "Attributes" do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:description) }
    it { should allow_mass_assignment_of(:start_date) }
    it { should allow_mass_assignment_of(:currency) }
    it { should allow_mass_assignment_of(:end_date) }
    it { should allow_mass_assignment_of(:currency) }
    it { should allow_mass_assignment_of(:data_response) }
    it { should allow_mass_assignment_of(:activities) }
    it { should allow_mass_assignment_of(:in_flows_attributes) }
    it { should allow_mass_assignment_of(:budget2) }
    it { should allow_mass_assignment_of(:budget3) }
    it { should allow_mass_assignment_of(:budget4) }
    it { should allow_mass_assignment_of(:budget5) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:data_response_id) }
    it { should allow_value('2010-12-01').for(:start_date) }
    it { should allow_value('2010-12-01').for(:end_date) }
    it { should_not allow_value('').for(:start_date) }
    it { should_not allow_value('').for(:end_date) }
    it { should_not allow_value('2010-13-01').for(:start_date) }
    it { should_not allow_value('2010-12-41').for(:start_date) }
    it { should_not allow_value('2010-13-01').for(:end_date) }
    it { should_not allow_value('2010-12-41').for(:end_date) }
    it { should_not allow_value('abcd').for(:budget2) }
    it { should_not allow_value('abcd').for(:budget3) }
    it { should_not allow_value('abcd').for(:budget4) }
    it { should_not allow_value('abcd').for(:budget5) }
    it { should validate_numericality_of(:budget2) }
    it { should validate_numericality_of(:budget3) }
    it { should validate_numericality_of(:budget4) }
    it { should validate_numericality_of(:budget5) }

    context "subject" do
      subject { basic_setup_project; @project }
      it { should validate_uniqueness_of(:name).scoped_to(:data_response_id) }

      it "should have a valid data_response " do
        subject.data_response.should_not be_nil
      end

      it "should return the owning organization " do
        lambda {subject.organization}.should_not raise_error
      end

      it " should NOT create workflow records after save" do
        subject.funding_flows.should have(0).items
      end
    end
  end

  describe "create" do
    it "should save without the optional currency override" do
      basic_setup_response
      p = Factory :project, :currency => "", :data_response => @response
      p.save.should == true
    end
  end

  describe "#locations" do
    it "returns uniq locations only from district classifications" do
      basic_setup_project
      activity1 = Factory(:activity, :data_response => @response, :project => @project)
      activity2 = Factory(:activity, :data_response => @response, :project => @project)
      location1 = Factory(:location)
      location2 = Factory(:location)
      Factory(:coding_budget_district, :activity => activity1, :code => location1)
      Factory(:coding_budget_district, :activity => activity1, :code => location2)
      Factory(:coding_budget_district, :activity => activity2, :code => location1)

      @project.locations.length.should == 2
      @project.locations.should include(location1)
      @project.locations.should include(location2)
    end
  end
end
