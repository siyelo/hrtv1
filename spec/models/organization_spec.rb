require File.dirname(__FILE__) + '/../spec_helper'

describe Organization do

  describe "attributes" do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:raw_type) }
    it { should allow_mass_assignment_of(:fosaid) }
  end

  describe "associations" do
    it { should have_and_belong_to_many(:activities) }
    it { should have_and_belong_to_many(:locations) }
    it { should have_many(:users) }
    it { should have_many(:data_requests) }
    it { should have_many(:data_responses) }
    it { should have_many(:projects) }
    it { should have_many(:dr_activities) }
    it { should have_many(:out_flows).dependent(:destroy) }
    it { should have_many(:in_flows).dependent(:destroy) }
    it { should have_many(:donor_for) }
    it { should have_many(:implementor_for) }
    it { should have_many(:provider_for) }
    it { should have_and_belong_to_many :managers }
  end

  describe "validations" do
    subject { Factory(:organization) }
    it { should be_valid }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:currency) }
    it { should validate_presence_of(:contact_name) }
    it { should validate_presence_of(:contact_position) }
    it { should validate_presence_of(:contact_phone_number) }
    it { should validate_presence_of(:contact_main_office_phone_number) }
    it { should validate_presence_of(:contact_office_location)}
  end

  describe "custom date validations" do
    it { should allow_mass_assignment_of(:fiscal_year_start_date) }
    it { should allow_mass_assignment_of(:fiscal_year_end_date) }
    it { should allow_mass_assignment_of(:currency) }
    it { should allow_mass_assignment_of(:contact_name) }
    it { should allow_mass_assignment_of(:contact_position) }
    it { should allow_mass_assignment_of(:contact_phone_number) }
    it { should allow_mass_assignment_of(:contact_main_office_phone_number) }
    it { should allow_mass_assignment_of(:contact_office_location) }
    it { should allow_value('2010-12-01').for(:fiscal_year_start_date) }
    it { should allow_value('2010-12-01').for(:fiscal_year_end_date) }
    #it { should_not allow_value('').for(:fiscal_year_start_date) }
    #it { should_not allow_value('').for(:fiscal_year_end_date) }
    #it { should_not allow_value('2010-13-01').for(:fiscal_year_start_date) }
    #it { should_not allow_value('2010-12-41').for(:fiscal_year_start_date) }
    #it { should_not allow_value('2010-13-01').for(:fiscal_year_end_date) }
    #it { should_not allow_value('2010-12-41').for(:fiscal_year_end_date) }

    it "accepts start date < end date (exactly 1 year)" do
      organization = Factory.build(:organization,
                         :fiscal_year_start_date => DateTime.new(2010, 01, 01),
                         :fiscal_year_end_date =>   DateTime.new(2010, 12, 31) )
      organization.should be_valid
    end

    it "does not accept an end date that is not one year after the start date" do
      organization = Factory.build(:organization,
                         :fiscal_year_start_date => DateTime.new(2010, 01, 01),
                         :fiscal_year_end_date =>   DateTime.new(2010, 12, 30) )
      organization.should_not be_valid
    end

    it "does not accept start date > end date" do
      organization = Factory.build(:organization,
                         :fiscal_year_start_date => DateTime.new(2010, 01, 02),
                         :fiscal_year_end_date =>   DateTime.new(2009, 01, 01) )
      organization.should_not be_valid
    end

    it "does not accept start date = end date" do
      organization = Factory.build(:organization,
                         :fiscal_year_start_date => DateTime.new(2010, 01, 01),
                         :fiscal_year_end_date =>   DateTime.new(2010, 01, 01) )
      organization.should_not be_valid
    end
  end

  describe "Callbacks" do
    # after_create :create_data_responses
    it "creates data_responsesfor each data_request after organization is created" do
      org0 = Factory(:organization, :name => "Requester Organization")
      data_request1 = Factory(:data_request, :organization => org0)
      data_request2 = Factory(:data_request, :organization => org0)

      organizations = Factory(:organization, :name => "Responder Organization")

      data_requests = organizations.data_responses.map(&:data_request)
      data_requests.should include(data_request1)
      data_requests.should include(data_request2)
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
      data_request1 = Factory(:data_request, :organization => @target)
      data_request2 = Factory(:data_request, :organization => @duplicate)
      @target_dr    = Factory(:data_response, :organization => @target, :data_request => data_request1)
      @duplicate_dr = Factory(:data_response, :organization => @duplicate, :data_request => data_request2)
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
      Organization.merge_organizations!(@target, @duplicate)
      @target.data_requests.count.should == 2
    end

    it "copies data responses from @duplicate to @target" do
      Organization.merge_organizations!(@target, @duplicate)
      @target.data_responses.count.should == 6
    end

    it "copies also invalid data responses from duplicate to @target" do
      @duplicate.fiscal_year_start_date = Date.parse("2010-02-01")
      @duplicate.fiscal_year_end_date = Date.parse("2010-01-01")
      @duplicate.save(false)
      duplicate_data_response = Factory.build(:data_response, :organization => @duplicate)
      duplicate_data_response.save
      Organization.merge_organizations!(@target, @duplicate)
      @target.data_responses.count.should == 9 # not 2, since our before block created a valid DR
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
    it "returns empty array when there are no organizations" do
      Organization.without_users.should be_empty
    end

    it "returns organizations without users" do
      req = Factory :request
      requestor = req.organization
      org1 = Factory(:organization, :name => 'Org1')
      Factory(:user, :organization => org1, :current_response => org1.responses.first)
      org2 = Factory(:organization, :name => 'Org2')
      Organization.without_users.should == [requestor, org2]
    end

    it "should order organizations by name" do
      org1 = Factory(:organization, :name => 'Org2')
      org2 = Factory(:organization, :name => 'Org1')

      Organization.ordered.should == [org2, org1]
    end
  end

  describe "#has_provider?" do
    before :each do
      @request = Factory.create(:data_request)

      @org1 = Factory.create(:organization)
      @org2 = Factory.create(:organization)

      @response1 = Factory.create(:data_response, :data_request => @request,
                                 :organization => @org1)
      @response2 = Factory.create(:data_response, :data_request => @request,
                                 :organization => @org2)


    end

    it "has X as provider when any of its activities has it as provider" do
      project1  = Factory.create(:project, :data_response => @response1)
      activity1 = Factory.create(:activity, :project => project1, :provider => @org2,
                                :data_response => @response1)

      @org1.has_provider?(@org2).should be_true
    end

    it "does not have X as provider when all of its activities does not have it as provider" do
      project1  = Factory.create(:project, :data_response => @response1)
      @org1.has_provider?(@org2).should be_false
    end
  end

  it "displays the quarters with their correct months" do
    o = Factory(:organization,
                :fiscal_year_start_date => DateTime.new(2010, 01, 01),
                :fiscal_year_end_date =>   DateTime.new(2010, 12, 31) )

    o.quarters_months("q1").should == "Jan '10 - Mar '10"
    o.quarters_months("q2").should == "Apr '10 - Jun '10"
    o.quarters_months("q3").should == "Jul '10 - Sep '10"
    o.quarters_months("q4").should == "Oct '10 - Dec '10"
  end

  describe "latest_response" do
    before :each do
      @req = Factory :request
      @org = Factory :organization
    end
    it "should return the last data response that was created on this org" do
      @org.latest_response.request.should == @req
    end

    it "should return nil if there is no response, though this means the Org is invalid!!" do
      @org.responses.each {|r| r.destroy}
      @org.reload
      @org.latest_response.should == nil
    end
  end

  describe "#user_emails" do
    it "should return email addresses of users in the organization, up to the limit" do
      @req = Factory :request
      @org = Factory :organization
      @reporter = Factory :user, :email => 'reporter@org.com', :organization => @org
      @reporter2 = Factory :user, :email => 'reporter2@org.com', :organization => @org
      @org.user_emails(1).should == ['reporter@org.com']
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

