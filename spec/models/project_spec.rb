require File.dirname(__FILE__) + '/../spec_helper'

describe Project do

  describe "associations" do
    it { should have_and_belong_to_many :locations }
    it { should have_many :funding_flows }
    it { should have_many :in_flows }
    it { should have_many :out_flows }
    it { should have_many :comments }
    it { should have_many :funding_sources }
    it { should have_many :providers }
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
    it { should allow_value(123.45).for(:entire_budget) }
    it { should allow_value('2010-12-01').for(:start_date) }
    it { should allow_value('2010-12-01').for(:end_date) }
    it { should_not allow_value('').for(:start_date) }
    it { should_not allow_value('').for(:end_date) }
    it { should_not allow_value('2010-13-01').for(:start_date) }
    it { should_not allow_value('2010-12-41').for(:start_date) }
    it { should_not allow_value('2010-13-01').for(:end_date) }
    it { should_not allow_value('2010-12-41').for(:end_date) }

    it "should remove commas from decimal fields on save" do
      [:spend, :budget, :entire_budget].each do |f|
        p = Project.new
        p.send(f.to_s + "=", "10,783,000.32")
        p.save
        p.send(f).should == 10783000.32
      end
    end

    it "should have a valid data_response " do
      project = Factory(:project)
      project.data_response.should_not be_nil
    end

    it "should return the owning organization " do
      project = Factory(:project)
      lambda {project.organization}.should_not raise_error
    end

    it " should NOT create workflow records after save" do
      proj  = Factory.create(:project)
      proj.funding_flows.should have(0).items
    end
  end

  context "Funding flows: " do
    before(:each) do
      @our_org       = Factory(:organization)
      @data_response = Factory(:data_response,
                                :organization => @our_org)
      @other_org     = Factory(:organization)
      @project       = Factory(:project,
                                :data_response => @data_response )
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

    it "does not accept start date > end date" do
      p = Factory.build(:project,
                        :start_date => DateTime.new(2010, 01, 02),
                        :end_date =>   DateTime.new(2010, 01, 01) )
      p.should_not be_valid
    end

    it "does not accept start date = end date" do
      p = Factory.build(:project,
                        :start_date => DateTime.new(2010, 01, 01),
                        :end_date =>   DateTime.new(2010, 01, 01) )
      p.should_not be_valid
    end

    it "accepts Total Budget >= Total Budget GOR" do
      p = Factory.build(:project,
                        :start_date => DateTime.new(2010, 01, 01),
                        :end_date =>   DateTime.new(2010, 01, 02),
                        :entire_budget => 900,
                        :budget =>        800 )
      p.should be_valid
    end

    it "accepts Total Budget = Total Budget GOR" do
      p = Factory.build(:project,
                      :start_date => DateTime.new(2010, 01, 01),
                      :end_date =>   DateTime.new(2010, 01, 02),
                        :entire_budget => 900,
                        :budget =>        900 )
      p.should be_valid
    end

    it "does not accept Total Budget < Total Budget GOR" do
      p = Factory.build(:project,
                        :start_date => DateTime.new(2010, 01, 01),
                        :end_date =>   DateTime.new(2010, 01, 02),
                        :entire_budget => 900,
                        :budget =>        1000 )
      p.should_not be_valid
    end
  end

  context "on delete" do
    it "should nullify funding flows on delete" do
      project = Factory(:project)
      flow    = Factory(:funding_flow,
                        :organization_id_from => project.organization,
                        :project => project,
                        :data_response => project.data_response)
      f = project.funding_flows.first
      project.destroy
      f.reload
      f.project.should == nil
    end
  end

  describe "counter cache" do
    context "comments cache" do
      before :each do
        @commentable = Factory.create(:project)
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

  describe 'Currency cache update' do
    before :each do
      Money.default_bank.add_rate(:RWF, :USD, 0.5)
      Money.default_bank.add_rate(:EUR, :USD, 1.5)

      @data_response = Factory(:data_response, :currency => 'RWF')
      @project       = Factory(:project,
                                :data_response => @data_response,
                                :currency => nil)
      @activity      = Factory(:activity, :project => @project,
                                :budget => 1000, :spend => 2000)

    end

    it "should return the Data Response currency if no currency overridden" do
      @project.currency.should == 'RWF'
      @project.currency = 'EUR'
      @project.save
      @project.currency.should == 'EUR'
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
end
