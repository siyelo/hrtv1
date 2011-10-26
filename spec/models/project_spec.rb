require File.dirname(__FILE__) + '/../spec_helper'
require 'set'

describe Project do
  describe "Associations" do
    subject { basic_setup_project; @project }
    it { should belong_to(:data_response) }
    it { should have_many(:activities).dependent(:destroy) }
    it { should have_many(:other_costs).dependent(:destroy) }
    it { should have_many(:normal_activities).dependent(:destroy) }
    it { should have_many(:funding_flows).dependent(:destroy) }
    it { should have_many(:in_flows) }
    it { should have_many(:out_flows) }
    it { should have_many(:comments) }
    it { should have_many(:comments) }
  end

  describe "Attributes" do
    subject { basic_setup_project; @project }
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:description) }
    it { should allow_mass_assignment_of(:start_date) }
    it { should allow_mass_assignment_of(:currency) }
    it { should allow_mass_assignment_of(:end_date) }
    it { should allow_mass_assignment_of(:data_response) }
    it { should allow_mass_assignment_of(:activities) }
    it { should allow_mass_assignment_of(:in_flows_attributes) }
  end

  describe "Validations" do
    subject { basic_setup_project; @project }
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

    it "should validate length of name" do
      basic_setup_response
      @project = Factory.build(:project, :name => nil, :data_response => @response)
      @project.save.should be_false
      # TODO - filter to just one error
      @project.errors.on(:name).should == ["can't be blank", "is too short (minimum is 1 characters)"]
      @project.name = "1111111111222222222233333333334444444444555555555566666666667777777777"
      @project.save.should be_false
      @project.errors.on(:name).should == "is too long (maximum is 64 characters)"
    end

    it "should have at least one funder" do
      @organization = Factory(:organization)
      @other_org    = Factory(:organization)
      @request      = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
      @project = Factory.build(:project, :data_response => @response, :in_flows => [])
      @project.save.should be_false
      @project.errors.on(:base).should == "Project must have at least one Funding Source."
    end

    context "subject" do
      subject { basic_setup_project; @project }
      it { should validate_uniqueness_of(:name).scoped_to(:data_response_id) }

      it "should have a valid data_response " do
        subject.data_response.should_not be_nil
      end

      it "should return the owning organization " do
        lambda {subject.organization}.should_not raise_error
      end

      it " should only create in_flow record on save" do
        subject.in_flows.should have(1).items
        subject.in_flows.first.to.should == @project.organization
      end

      it " should only create in_flow record on save" do
        subject.reload
        subject.funding_flows.should have(1).items
        subject.funding_flows.first.to.should == @project.organization
      end
    end
  end

  describe "create" do
    it "should create a new project object with (unsaved) nested associations" do
      basic_setup_response
      p = Project.new(:name => "new project", :description => "new description",
      :data_response => @response, :start_date => "2010-01-01", :end_date => "2010-12-31",
      :in_flows_attributes => { "0" => {:organization_id_from => "a new org plox k thx",
        :budget => 10, :spend => 20}})
      p.in_flows.should have(1).item
      p.save.should == true
    end

    it "should create a new project object with (unsaved) nested associations" do
      basic_setup_response
      p = Project.new(
        {"name"=>"Kuraneza", "start_date"=>"2011-08-29",
         "in_flows_attributes"=> {"0"=>{"organization_id_from"=>"#{@organization.id}", "spend"=>"1", "budget"=>"1"}},
         "data_response_id"=>"#{@response.id}", "_destroy"=>"", "currency"=>"RWF", "description"=>"Describe the proje",
         "end_date"=>"2012-08-29",
         "activities_attributes"=>
            {"0"=>{"name"=>"Activity name not more than 64 characters otherwise you will not",
             "data_response_id" => @response.id , "implementer_splits_attributes"=>
              {"0"=>{"updated_at"=>"", "spend"=>"6000.0", "data_response_id"=>"#{@response.id}",
                     "organization_mask"=>"#{@organization.id}", "budget"=>"10000.0", "_destroy"=>""}},
           "description"=>"Description of activity"}}}
      )
      p.in_flows.should have(1).item
      p.activities.should have(1).item
      p.save.should == true
    end

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

  describe "#in_flows_total" do
    it "should return sum of spends/budgets" do
      basic_setup_project
      @donor1 = Factory :organization
      @donor2 = Factory :organization
      @response1     = @donor1.latest_response
      @response2     = @donor2.latest_response
      @project1      = Factory(:project, :data_response => @response1, :in_flows =>
        [ Factory.build(:funding_flow, :from => @donor1, :spend => 10, :budget => 20),
          Factory.build(:funding_flow, :from => @donor2, :spend => 10, :budget => 20)])
      @project1.in_flows_total(:budget).to_f.should == 40
      @project1.in_flows_total(:spend).to_f.should == 20
    end
  end
end
