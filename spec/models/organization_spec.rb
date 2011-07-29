require File.dirname(__FILE__) + '/../spec_helper'

describe Organization do

  describe "Attributes" do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:raw_type) }
    it { should allow_mass_assignment_of(:fosaid) }
    it { should allow_mass_assignment_of(:currency) }
    it { should allow_mass_assignment_of(:contact_name) }
    it { should allow_mass_assignment_of(:contact_position) }
    it { should allow_mass_assignment_of(:contact_phone_number) }
    it { should allow_mass_assignment_of(:contact_main_office_phone_number) }
    it { should allow_mass_assignment_of(:contact_office_location) }
    it { should allow_mass_assignment_of(:provider_type) }
  end

  describe "Associations" do
    it { should have_and_belong_to_many(:activities) }
    it { should have_and_belong_to_many(:locations) }
    it { should have_many(:users) }
    it { should have_many(:data_requests) }
    it { should have_many(:data_responses) }
    it { should have_many(:projects) }
    it { should have_many(:dr_activities) }
    it { should have_many(:out_flows).dependent(:nullify) }
    it { should have_many(:in_flows).dependent(:nullify) }
    it { should have_many(:donor_for) }
    it { should have_many(:implementor_for) }
    it { should have_many(:provider_for).dependent(:nullify) }
  end

  describe "Validations" do
    subject { Factory(:organization) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }

    it "validates presence of attributes only on update" do
      attributes = {
        :currency => nil,
        :contact_name => nil,
        :contact_position => nil,
        :contact_phone_number => nil,
        :contact_main_office_phone_number => nil,
        :contact_office_location => nil
      }

      organization = Factory(:organization, attributes) # create valid org

      # try updating with invalid attributes
      organization.update_attributes(attributes).should be_false
      organization.errors.on(:currency).should_not be_blank
      organization.errors.on(:contact_name).should_not be_blank
      organization.errors.on(:contact_position).should_not be_blank
      organization.errors.on(:contact_phone_number).should_not be_blank
      organization.errors.on(:contact_main_office_phone_number).should_not be_blank
      organization.errors.on(:contact_office_location).should_not be_blank
    end

    it "is valid when currency is included in the list" do
      organization = Factory.build(:organization, :currency => 'USD')
      organization.save
      organization.errors.on(:currency).should be_blank
    end

    it "allows only one organization with raw_type Government" do
      org0 = Factory.build(:organization, :raw_type => 'Government')
      org0.save
      org1 = Factory.build(:organization, :raw_type => 'Government')
      org1.save
      org1.errors.on(:raw_type).should_not be_blank
    end
  end

  describe "Callbacks" do
    # after_create :create_data_responses
    it "creates data_responses for each data_request after organization is created" do
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
      basic_setup_project
    end

    it "can have many in_flows" do
      @organization.in_flows.should have(0).items
      Factory(:funding_flow, :data_response => @response,
              :project => @project, :to => @organization)
      @organization.reload
      @organization.in_flows.should have(1).item
    end

    it "can have many out_flows" do
      @organization.out_flows.should have(0).items
      Factory(:funding_flow, :data_response => @response,
              :project => @project, :from => @organization)
      @organization.reload
      @organization.out_flows.should have(1).item
    end

    it "can donate to a project" do
      @organization.donor_for.should have(0).items
      Factory(:funding_flow, :data_response => @response,
              :project => @project, :from => @organization)
      @organization.reload
      @organization.donor_for.should have(1).item
    end

    it "can implement a project" do
      @organization.implementor_for.should have(0).items
      Factory(:funding_flow, :data_response => @response,
              :project => @project, :to => @organization)
      @organization.reload
      @organization.implementor_for.should have(1).item
      @organization.implementor_for.first.should == @project
    end
  end

  describe "empty organization" do
    before :each do
      @organization = Factory(:organization)
      @request      = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
    end

    it "is empty when it has empty data response" do
      @organization.is_empty?.should be_true
    end

    it "is not empty when it has non empty data response" do
      Factory(:project, :data_response => @response)
      @organization.reload
      @organization.is_empty?.should_not be_true
    end

    it "is not empty when it has users" do
      Factory(:reporter, :organization => @organization)
      @organization.reload
      @organization.is_empty?.should_not be_true
    end

    it "is not empty when it has in flows" do
      project = Factory(:project, :data_response => @response)
      Factory(:funding_flow, :data_response => @response,
              :to => @organization, :project => project)
      @organization.reload
      @organization.is_empty?.should_not be_true
    end

    it "is not empty when it has out flows" do
      project = Factory(:project, :data_response => @response)
      Factory(:funding_flow, :data_response => @response,
              :from => @organization, :project => project)
      @organization.reload
      @organization.is_empty?.should_not be_true
    end

    it "is not empty when it has provider_for" do
      project  = Factory(:project, :data_response => @response)
      activity = Factory(:activity, :data_response => @response, :project => project)
      @organization.reload
      @organization.is_empty?.should_not be_true
    end

    it "is not empty when it has locations" do
      @organization.locations << Factory.create(:location)
      @organization.is_empty?.should_not be_true
    end

    it "is not empty when it has activities" do
      project  = Factory(:project, :data_response => @response)
      activity = Factory(:activity, :data_response => @response, :project => project)
      @organization.is_empty?.should_not be_true
    end
  end


  describe "CSV" do
    before :each do
      @organization = Factory(:organization, :name => 'blarorg', :raw_type => 'NGO', :fosaid => "13")
    end

    it "will return just the headers if no organizations are passed" do
      org_headers = Organization.download_template
      org_headers.should == "name,raw_type,fosaid\n"
    end
  end


  describe "remove duplicate organization" do
    before :each do
      @target       = Factory(:organization)
      @duplicate    = Factory(:organization)
      data_request1 = Factory(:data_request, :organization => @target)
      data_request2 = Factory(:data_request, :organization => @duplicate)
      @target_dr    = @target.latest_response
      @duplicate_dr = @duplicate.latest_response
    end

    it "deletes duplicate after merge" do
      Organization.merge_organizations!(@target, @duplicate)
      all_organizations = Organization.all
      all_organizations.should include(@target)
      all_organizations.should_not include(@duplicate)
    end

    it "copies activities from @duplicate to @target" do
      target_project     = Factory(:project, :data_response => @target_dr)
      duplicate_project  = Factory(:project, :data_response => @duplicate_dr)

      target_activity    = Factory(:activity, :data_response => @target_dr,
                                   :project => target_project)
      duplicate_activity = Factory(:activity, :data_response => @duplicate_dr,
                                   :project => duplicate_project)

      @target.activities << target_activity
      @duplicate.activities << duplicate_activity
      @target.activities.count.should == 1
      Organization.merge_organizations!(@target, @duplicate)
      @target.activities.count.should == 2
    end

    it "copies data_requests from duplicate to @target" do
      Organization.merge_organizations!(@target, @duplicate)
      @target.data_requests.count.should == 2
    end

    it "copies data responses from @duplicate to @target" do
      Organization.merge_organizations!(@target, @duplicate)
      @target.data_responses.count.should == 4
    end

    it "copies also invalid data responses from duplicate to @target" do
      @duplicate.currency = "Derp"
      @duplicate.save(false)
      duplicate_data_response = @duplicate.latest_response
      Organization.merge_organizations!(@target, @duplicate)
      @target.data_responses.count.should == 4 # not 2, since our before block created a valid DR
    end

    it "copies out flows from duplicate to @target" do
      project_from = Factory(:project, :data_response => @target_dr)
      project_to   = Factory(:project, :data_response => @duplicate_dr)
      Factory(:funding_flow, :data_response => @target_dr,
              :from => @target, :project => project_from)
      Factory(:funding_flow, :data_response => @duplicate_dr,
              :from => @duplicate, :project => project_to)

      @target.out_flows.count.should == 1
      Organization.merge_organizations!(@target, @duplicate)
      @target.out_flows.count.should == 2
    end

    it "copies in flows from duplicate to @target" do
      project_from = Factory(:project, :data_response => @target_dr)
      project_to   = Factory(:project, :data_response => @duplicate_dr)
      Factory(:funding_flow, :data_response => @target_dr,
              :to => @target, :project => project_from)
      Factory(:funding_flow, :data_response => @duplicate_dr,
              :to => @duplicate, :project => project_to)

      @target.in_flows.count.should == 1
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
      Factory(:reporter, :organization => @target)
      Factory(:reporter, :organization => @duplicate)
      Organization.merge_organizations!(@target, @duplicate)
      @target.users.count.should == 2
    end

    it "copies provider_for from @duplicate to @target" do
      target_project = Factory(:project, :data_response => @target_dr)
      duplicate_project = Factory(:project, :data_response => @duplicate_dr)
      Factory(:activity, :provider => @target, :data_response => @target_dr,
              :project => target_project)
      Factory(:activity, :provider => @target, :data_response => @target_dr,
              :project => duplicate_project)
      Organization.merge_organizations!(@target, @duplicate)
      @target.provider_for.count.should == 2
    end
  end

  describe "counter cache" do
    it "caches users count" do
      o = Factory.create(:organization)
      o.users_count.should == 0
      Factory.create(:reporter, :organization => o)
      o.reload.users_count.should == 1
      Factory.create(:reporter, :organization => o)
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
      Factory(:reporter, :organization => org1, :current_response => org1.responses.first)
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

      @response1 = @org1.latest_response
      @response2 = @org2.latest_response
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
      @reporter = Factory :reporter, :email => 'reporter@org.com', :organization => @org
      @reporter2 = Factory :reporter, :email => 'reporter2@org.com', :organization => @org
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

