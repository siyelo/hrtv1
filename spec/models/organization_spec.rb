require File.dirname(__FILE__) + '/../spec_helper'

describe Organization do

  describe "attributes" do
    it { should allow_mass_assignment_of(:name) }
  end

  describe "validations" do
    subject { Factory(:organization) }
    it { should be_valid }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe "associations" do
    it { should have_and_belong_to_many :activities }
    it { should have_and_belong_to_many :locations }
    it { should have_many :users }
    it { should have_many :data_requests }
    it { should have_many :data_responses }
    it { should have_many :fulfilled_data_requests }
    it { should have_many :dr_activities }
    it { should have_many :out_flows }
    it { should have_many :in_flows }
    it { should have_many :donor_for }
    it { should have_many :implementor_for }
    it { should have_many :provider_for }

    it "returns fulfilled_data_requests" do
      organization = Factory.create(:organization)
      data_request1 = Factory.create(:data_request)
      data_request2 = Factory.create(:data_request)
      Factory.create(:data_response, :data_request => data_request1,
                     :organization => organization)

      organization.fulfilled_data_requests.should == [data_request1]
    end
  end

  describe "unfulfilled_data_requests" do
    it "returns empty array when no data requests" do
      organization = Factory.create(:organization)
      organization.unfulfilled_data_requests.should == []
    end

    it "returns empty array when no data requests" do
      organization = Factory.create(:organization)
      data_request1 = Factory.create(:data_request)
      data_request2 = Factory.create(:data_request)
      Factory.create(:data_response, :data_request => data_request1,
                     :organization => organization)

      organization.unfulfilled_data_requests.should == [data_request2]
    end
  end

  describe "creating a organization record" do
    before :each do
      @organization = Factory(:organization)
      Factory(:data_response, :organization => @organization)
    end

    it "can have many in_flows" do
      @organization.in_flows.should have(0).items
      Factory(:funding_flow,
              :to => @organization,
              :data_response => @organization.data_responses.first)
      @organization.reload
      @organization.in_flows.should have(1).item
    end

    it "can have many out_flows" do
      @organization.out_flows.should have(0).items
      Factory(:funding_flow,
                      :from => @organization,
                      :data_response => @organization.data_responses.first)
      @organization.reload
      @organization.out_flows.should have(1).item
    end

    context "flows to/from projects" do
      before :each do
        @project = Factory(:project,
                           :data_response => @organization.data_responses.first)
      end

      it "can donate to a project" do
        @organization.donor_for.should have(0).items
        Factory(:funding_flow,
                        :from => @organization,
                        :project => @project,
                        :data_response => @organization.data_responses.first)
        @organization.reload
        @organization.donor_for.should have(1).item
      end

      it "can implement a project" do
        @organization.implementor_for.should have(0).items
        Factory(:funding_flow,
                        :to => @organization,
                        :project => @project,
                        :data_response => @organization.data_responses.first)
        @organization.reload
        @organization.implementor_for.should have(1).item
        @organization.implementor_for.first.should == @project
      end
    end
  end

  describe "empty organization" do
    before :each do
      @organization = Factory(:organization)
    end

    it "is empty when it has nothing" do
      @organization.is_empty?.should be_true
    end

    it "is empty when it has empty data response" do
      dr = Factory(:data_response)
      @organization.is_empty?.should be_true
    end

    it "is not empty when it has non empty data response" do
      dr = Factory(:data_response, :organization => @organization)
      Factory(:project, :data_response => dr)
      @organization.reload
      @organization.is_empty?.should_not be_true
    end

    it "is not empty when it has users" do
      Factory(:user, :organization => @organization)
      @organization.reload
      @organization.is_empty?.should_not be_true
    end

    it "is not empty when it has in flows" do
      Factory(:data_response, :organization => @organization)
      Factory(:funding_flow,
                      :to => @organization,
                      :data_response => @organization.data_responses.first)
      @organization.reload
      @organization.is_empty?.should_not be_true
    end

    it "is not empty when it has out flows" do
      Factory(:data_response, :organization => @organization)
      Factory(:funding_flow,
                      :from => @organization,
                      :data_response => @organization.data_responses.first)
      @organization.reload
      @organization.is_empty?.should_not be_true
    end

    it "is not empty when it has provider_for" do
      Factory(:activity, :provider => @organization)
      @organization.reload
      @organization.is_empty?.should_not be_true
    end

    it "is not empty when it has locations" do
      @organization.locations << Factory.create(:location)
      @organization.is_empty?.should_not be_true
    end

    it "is not empty when it has activities" do
      @organization.activities << Factory.create(:activity)
      @organization.is_empty?.should_not be_true
    end
  end


  describe "remove duplicate organization" do
    before :each do
      @target     = Factory(:organization)
      @duplicate  = Factory(:organization)

      @target_dr     = Factory(:data_response, :organization => @target)
      @duplicate_dr  = Factory(:data_response, :organization => @duplicate)
    end

    it "deletes duplicate after merge" do
      Organization.merge_organizations!(@target, @duplicate)
      all_organizations = Organization.all
      all_organizations.should include(@target)
      all_organizations.should_not include(@duplicate)
    end

    it "copies activities from @duplicate to @target" do
      @target.activities << Factory(:activity)
      @duplicate.activities << Factory(:activity)
      Organization.merge_organizations!(@target, @duplicate)
      @target.activities.count.should == 2
    end

    it "copies data_requests from duplicate to @target" do
      Factory(:data_request, :organization => @target)
      Factory(:data_request, :organization => @duplicate)
      Organization.merge_organizations!(@target, @duplicate)
      @target.data_requests.count.should == 2
    end

    it "copies data responses from @duplicate to @target" do
      Organization.merge_organizations!(@target, @duplicate)
      @target.data_responses.count.should == 2
    end

    it "copies also invalid data responses from duplicate to @target" do
      duplicate_data_response = Factory.build(:data_response, :organization => @duplicate,
                    :fiscal_year_start_date => Date.parse("2010-02-01"),
                    :fiscal_year_end_date => Date.parse("2010-01-01"))
      duplicate_data_response.save(false)
      Organization.merge_organizations!(@target, @duplicate)
      @target.data_responses.count.should == 3 # not 2, since our before block created a valid DR
    end

    it "copies out flows from duplicate to @target" do
      Factory(:funding_flow,
                      :from => @target,
                      :data_response => @target.data_responses.first)
      Factory(:funding_flow,
                      :from => @duplicate,
                      :data_response => @target.data_responses.first)
      Organization.merge_organizations!(@target, @duplicate)
      @target.out_flows.count.should == 2
    end

    it "copies in flows from duplicate to @target" do
      Factory(:funding_flow,
                      :to => @target,
                      :data_response => @target.data_responses.first)
      Factory(:funding_flow,
                      :to => @duplicate,
                      :data_response => @target.data_responses.first)
      Organization.merge_organizations!(@target, @duplicate)
      @target.in_flows.count.should == 2
    end

    it "copies locations from duplicate to @target" do
      @target.locations << Factory(:location)
      @duplicate.locations << Factory(:location)
      Organization.merge_organizations!(@target, @duplicate)
      @target.locations.count.should == 2
    end

    it "copies users from @duplicate to @target" do
      Factory(:user, :organization => @target)
      Factory(:user, :organization => @duplicate)
      Organization.merge_organizations!(@target, @duplicate)
      @target.users.count.should == 2
    end

    it "copies provider_for from @duplicate to @target" do
      Factory(:activity, :provider => @target)
      Factory(:activity, :provider => @duplicate)
      Organization.merge_organizations!(@target, @duplicate)
      @target.provider_for.count.should == 2
    end
  end

  describe "counter cache" do
    context "comments cache" do
      before :each do
        @commentable = Factory.create(:organization)
      end

      it_should_behave_like "comments_cacher"
    end

    it "caches users count" do
      o = Factory.create(:organization)
      o.users_count.should == 0
      Factory.create(:user, :organization => o)
      o.reload.users_count.should == 1
      Factory.create(:user, :organization => o)
      o.reload.users_count.should == 2
    end
  end

  describe "named_scopes" do
    describe "without_users" do
      it "returns empty array when there are no organizations" do
        Organization.without_users.should be_empty
      end

      it "returns organizations without users" do
        org1 = Factory(:organization, :name => 'Org1')
        Factory(:user, :organization => org1)

        org2 = Factory(:organization, :name => 'Org2')

        Organization.without_users.should == [org2]
      end
    end

    describe "ordered" do
      it "should order organizations by name" do
        org1 = Factory(:organization, :name => 'Org2')
        org2 = Factory(:organization, :name => 'Org1')

        Organization.ordered.should == [org2, org1]
      end
    end
  end
end

# == Schema Information
#
# Table name: organizations
#
#  id             :integer         primary key
#  name           :string(255)
#  type           :string(255)
#  created_at     :timestamp
#  updated_at     :timestamp
#  raw_type       :string(255)
#  fosaid         :string(255)
#  users_count    :integer         default(0)
#  comments_count :integer         default(0)
#

