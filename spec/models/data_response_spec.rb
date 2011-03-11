require File.dirname(__FILE__) + '/../spec_helper'

describe DataResponse do

  describe "associations" do
    it { should belong_to(:organization) }
    it { should belong_to(:data_request) }
    it { should have_many(:activities) }
    it { should have_many(:sub_activities) }
    it { should have_many(:funding_flows) }
    it { should have_many(:projects) }
    it { should have_many(:users_currently_completing) }
  end

  describe "validations" do
    it { should validate_presence_of(:data_request_id) }
    it { should validate_presence_of(:organization_id) }
    it { should validate_presence_of(:currency) }
  end

  describe "custom date validations" do
    it { should allow_mass_assignment_of(:fiscal_year_start_date) }
    it { should allow_mass_assignment_of(:fiscal_year_end_date) }
    it { should allow_mass_assignment_of(:currency) }
    it { should allow_mass_assignment_of(:contact_name) }
    it { should allow_mass_assignment_of(:contact_name) }
    it { should allow_mass_assignment_of(:contact_position) }
    it { should allow_mass_assignment_of(:contact_phone_number) }
    it { should allow_mass_assignment_of(:contact_main_office_phone_number) }
    it { should allow_mass_assignment_of(:contact_office_location) }
    it { should allow_value('2010-12-01').for(:fiscal_year_start_date) }
    it { should allow_value('2010-12-01').for(:fiscal_year_end_date) }
    it { should_not allow_value('').for(:fiscal_year_start_date) }
    it { should_not allow_value('').for(:fiscal_year_end_date) }
    it { should_not allow_value('2010-13-01').for(:fiscal_year_start_date) }
    it { should_not allow_value('2010-12-41').for(:fiscal_year_start_date) }
    it { should_not allow_value('2010-13-01').for(:fiscal_year_end_date) }
    it { should_not allow_value('2010-12-41').for(:fiscal_year_end_date) }

    it "accepts start date < end date" do
      dr = Factory.build(:data_response,
                         :fiscal_year_start_date => DateTime.new(2010, 01, 01),
                         :fiscal_year_end_date =>   DateTime.new(2010, 01, 02) )
      dr.should be_valid
    end

    it "does not accept start date > end date" do
      dr = Factory.build(:data_response,
                         :fiscal_year_start_date => DateTime.new(2010, 01, 02),
                         :fiscal_year_end_date =>   DateTime.new(2010, 01, 01) )
      dr.should_not be_valid
    end

    it "does not accept start date = end date" do
      dr = Factory.build(:data_response,
                         :fiscal_year_start_date => DateTime.new(2010, 01, 01),
                         :fiscal_year_end_date =>   DateTime.new(2010, 01, 01) )
      dr.should_not be_valid
    end

  end

  describe "counter cache" do
    context "comments cache" do
      before :each do
        @commentable = Factory.create(:data_response)
      end

      it_should_behave_like "comments_cacher"
    end

    it "caches projects count" do
      dr = Factory.create(:data_response)
      dr.projects_count.should == 0
      Factory.create(:project, :data_response => dr)
      dr.reload.projects_count.should == 1
      Factory.create(:project, :data_response => dr)
      dr.reload.projects_count.should == 2
    end

    it "caches activities count" do
      dr = Factory.create(:data_response)
      dr.activities_count.should == 0
      Factory.create(:activity, :data_response => dr)
      dr.reload.activities_count.should == 1
      Factory.create(:activity, :data_response => dr)
      dr.reload.activities_count.should == 2
    end

    it "caches sub activities count" do
      dr = Factory.create(:data_response)
      dr.sub_activities_count.should == 0
      Factory.create(:sub_activity, :data_response => dr)
      dr.reload.sub_activities_count.should == 1
      Factory.create(:sub_activity, :data_response => dr)
      dr.reload.sub_activities_count.should == 2
    end

    it "caches activities without projects count" do
      dr = Factory.create(:data_response)
      dr.activities_without_projects_count.should == 0
      # need to create bad data to set up this fixture
      #Factory.create(:activity, :data_response => dr, :projects => []) # is invalid
      @project = Factory(:project, :data_response => dr)
      Factory.create(:activity, :data_response => dr, :projects => [@project]) 
      @project.destroy
      dr.reload.activities_without_projects_count.should == 1
      @project = Factory(:project, :data_response => dr)
      Factory.create(:activity, :data_response => dr, :projects => [@project]) 
      @project.destroy
      dr.reload.activities_without_projects_count.should == 2
    end
  end

  describe "searching for in-progress data responses" do
    it "should not be in progress on creation" do
      @dr = Factory.create(:data_response)
      DataResponse.in_progress.should_not include(@dr)
    end
    it "should be in progress if it has a project" do
      @dr   = Factory(:data_response)
      @proj = Factory(:project, :data_response => @dr)
      DataResponse.in_progress.should include(@dr)
    end
  end

  describe 'Currency cache update' do
    before :each do
      Money.default_bank.add_rate(:RWF, :USD, 0.5)
      Money.default_bank.add_rate(:EUR, :USD, 1.5)
      @dr        = Factory(:data_response, :currency => 'RWF')
      @project   = Factory(:project, :data_response => @dr,
                            :currency => nil)
      @activity  = Factory(:activity, :data_response => @dr,
                            :projects => [@project],
                            :budget => 1000, :spend => 2000)

    end

    it "should update cached USD amounts on Activity and Code Assignment" do
      @activity.budget_in_usd.should == 500
      @activity.spend_in_usd.should == 1000
      @dr.reload # dr.activities wont be updated otherwise
      @dr.currency = 'EUR'
      @dr.save
      @activity.reload
      @activity.budget_in_usd.should == 1500
      @activity.spend_in_usd.should == 3000
    end
  end
end


# == Schema Information
#
# Table name: data_responses
#
#  id                                :integer         primary key
#  data_request_id                   :integer
#  complete                          :boolean         default(FALSE)
#  created_at                        :timestamp
#  updated_at                        :timestamp
#  organization_id                   :integer
#  currency                          :string(255)
#  fiscal_year_start_date            :date
#  fiscal_year_end_date              :date
#  contact_name                      :string(255)
#  contact_position                  :string(255)
#  contact_phone_number              :string(255)
#  contact_main_office_phone_number  :string(255)
#  contact_office_location           :string(255)
#  submitted                         :boolean
#  submitted_at                      :timestamp
#  projects_count                    :integer         default(0)
#  comments_count                    :integer         default(0)
#  activities_count                  :integer         default(0)
#  sub_activities_count              :integer         default(0)
#  activities_without_projects_count :integer         default(0)
#

