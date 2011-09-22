require File.dirname(__FILE__) + '/../spec_helper'

describe Organization do

  describe "Attributes" do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:location_id) }
    it { should allow_mass_assignment_of(:raw_type) }
    it { should allow_mass_assignment_of(:fosaid) }
    it { should allow_mass_assignment_of(:currency) }
    it { should allow_mass_assignment_of(:fiscal_year_end_date) }
    it { should allow_mass_assignment_of(:fiscal_year_start_date) }
    it { should allow_mass_assignment_of(:contact_name) }
    it { should allow_mass_assignment_of(:contact_position) }
    it { should allow_mass_assignment_of(:contact_phone_number) }
    it { should allow_mass_assignment_of(:contact_main_office_phone_number) }
    it { should allow_mass_assignment_of(:contact_office_location) }
  end

  describe "Associations" do
    it { should have_many(:activities) }
    it { should belong_to(:location) }
    it { should have_many(:users) }
    it { should have_many(:data_requests) }
    it { should have_many(:data_responses) }
    it { should have_many(:projects) }
    it { should have_many(:dr_activities) }
    it { should have_many(:out_flows).dependent(:nullify) }
    it { should have_many(:donor_for) }
    it { should have_many(:implemented_activities).dependent(:nullify) }
    it { should have_and_belong_to_many :managers }
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
  end

  describe "custom date validations" do
    it { should allow_mass_assignment_of(:fiscal_year_start_date) }
    it { should allow_mass_assignment_of(:fiscal_year_end_date) }
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

  describe "Named Scopes" do
    before :each do
      request_org   = Factory(:organization)
      @response_org = Factory(:organization)
      @request1     = Factory(:data_request, :organization => request_org)
      @response1    = @response_org.latest_response
      @request2     = Factory(:data_request, :organization => request_org)
      @response2    = @response_org.latest_response
    end

    it "returns responses by states" do
      Organization.responses_by_states(@request1, ['started']).should be_empty
      Organization.responses_by_states(@request2, ['started']).should be_empty
      Organization.responses_by_states(@request1, ['rejected']).should be_empty
      Organization.responses_by_states(@request2, ['rejected']).should be_empty

      @response1.state = 'started'
      @response1.save

      Organization.responses_by_states(@request1, ['started']).should == [@response_org]
      Organization.responses_by_states(@request2, ['started']).should be_empty
      Organization.responses_by_states(@request1, ['rejected']).should be_empty
      Organization.responses_by_states(@request2, ['rejected']).should be_empty

      @response2.state = 'rejected'
      @response2.save

      Organization.responses_by_states(@request1, ['started']).should == [@response_org]
      Organization.responses_by_states(@request2, ['started']).should be_empty
      Organization.responses_by_states(@request1, ['rejected']).should be_empty
      Organization.responses_by_states(@request2, ['rejected']).should == [@response_org]
      Organization.responses_by_states(@request1, ['started', 'rejected']).should == [@response_org]
    end
  end

  describe "Responses" do
    before :each do
      @organization1 = Factory(:organization)
      @organization2 = Factory(:organization)
      @request       = Factory(:data_request, :organization => @organization1)
      @response1    = @organization1.latest_response
      @response2    = @organization2.latest_response
    end

    it "returns unstarted responses" do
      responses = Organization.unstarted_responses(@request)
      responses.should include(@organization1)
      responses.should include(@organization2)
    end

    it "returns started responses" do
      @response1.state = 'started'
      @response1.save!
      responses = Organization.started_responses(@request)
      responses.should include(@organization1)
      responses.should_not include(@organization2)
    end

    it "returns submitted responses" do
      @response1.state = 'submitted'
      @response1.save!
      responses = Organization.submitted_responses(@request)
      responses.should include(@organization1)
      responses.should_not include(@organization2)
    end

    it "returns rejected responses" do
      @response1.state = 'rejected'
      @response1.save!
      responses = Organization.rejected_responses(@request)
      responses.should include(@organization1)
      responses.should_not include(@organization2)
    end

    it "returns accepted responses" do
      @response1.state = 'accepted'
      @response1.save!
      responses = Organization.accepted_responses(@request)
      responses.should include(@organization1)
      responses.should_not include(@organization2)
    end
  end

  describe "Callbacks" do
    context "when there is a data_request in the system" do
      # after_create :create_data_responses
      it "creates data_responses for each data_request after organization is created" do
        org_requester = Factory(:organization)
        data_request1 = Factory(:data_request, :organization => org_requester)
        data_request2 = Factory(:data_request, :organization => org_requester)

        organization = Factory(:organization)

        data_requests = organization.data_responses.map(&:data_request)
        data_requests.should include(data_request1)
        data_requests.should include(data_request2)
      end

      it "does not create data_responses for Non-Reporting organizations" do
        org_requester = Factory(:organization)
        Factory(:data_request, :organization => org_requester)

        organization = Factory(:organization, :raw_type => 'Non-Reporting')
        organization.data_responses.should be_empty
      end
    end

    context "when there is no a data_request in the system" do
      # after_create :create_data_responses
      it "creates data_responses for each data_request after organization is created" do
        org_requester = Factory(:organization)
        data_request1 = Factory(:data_request, :organization => org_requester)
        data_request2 = Factory(:data_request, :organization => org_requester)

        data_requests = org_requester.data_responses.map(&:data_request)
        data_requests.should include(data_request1)
        data_requests.should include(data_request2)
      end

      it "does not create data_responses for Non-Reporting organizations" do
        org_requester = Factory(:organization, :raw_type => 'Non-Reporting')
        Factory(:data_request, :organization => org_requester)

        org_requester.data_responses.should be_empty
      end
    end
  end

  describe "#last logged in user" do
    before :each do
      @org = Factory.build(:organization)
      @user = Factory.build(:user,
        :last_login_at => DateTime.parse('2009-05-04 02:00:00'),
        :current_login_at => DateTime.parse('2009-06-04 02:00:00'))
      @org.users << @user
    end

    it "returns the last user in that organization that logged in if there is one user" do
      @org.last_user_logged_in.should == @user
      @org.current_user_logged_in.should == @user
      @org.last_or_current_user_logged_in.should == @user
    end

    it "returns nil when nobody has ever logged in" do
      @user.last_login_at = nil
      @user.current_login_at = nil
      user2 = Factory.build(:user, :organization => @org)
      @org.users << @user; @org.users << user2
      @org.last_user_logged_in.should be_nil
      @org.current_user_logged_in.should be_nil
      @org.last_or_current_user_logged_in.should be_nil
    end

    # authlogic idiosyncracy
    it " returns last logged in as nil on first sign in" do
      @user.last_login_at = nil
      @org.last_user_logged_in.should be_nil
      @org.current_user_logged_in.should == @user
      @org.last_or_current_user_logged_in.should == @user
    end
  end

  describe "creating a organization record" do
    before :each do
      basic_setup_project
    end

    it "can have many out_flows" do
      @organization.out_flows.should have(0).items
      Factory(:funding_flow,
              :project => @project, :from => @organization)
      @organization.reload
      @organization.out_flows.should have(1).item
    end

    it "can donate to a project" do
      @organization.donor_for.should have(0).items
      Factory(:funding_flow,
              :project => @project, :from => @organization)
      @organization.reload
      @organization.donor_for.should have(1).item
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

    it "is not empty when it has out flows" do
      # project factory creates out flow from organization to this project
      project = Factory(:project, :data_response => @response)
      @organization.reload
      @organization.is_empty?.should_not be_true
    end

    it "is not empty when it has implemented activities" do
      project  = Factory(:project, :data_response => @response)
      activity = Factory(:activity, :data_response => @response, :project => project)
      @organization.reload
      @organization.is_empty?.should_not be_true
    end

    it "is not empty when it has a location" do
      @organization.location = Factory.create(:location)
      @organization.is_empty?.should_not be_true
    end

    it "is not empty when it has activities" do
      project  = Factory(:project, :data_response => @response)
      activity = Factory(:activity, :data_response => @response, :project => project)
      @organization.reload
      @organization.is_empty?.should_not be_true
    end
  end

  describe "CSV" do
    before :each do
      @organization = Factory(:organization, :name => 'blarorg', :raw_type => 'NGO', :fosaid => "13")
    end

    it "will return just the headers if no organizations are passed" do
      org_headers = Organization.download_template
      org_headers.should == "name,raw_type,fosaid,currency\n"
    end

    it "will return a list of organizations if there are present" do
      organizations = Organization.all
      orgs = Organization.download_template(organizations)
      orgs.should == "name,raw_type,fosaid,currency\nblarorg,NGO,13,USD\n"
    end
  end


  describe "remove duplicate organization" do
    before :each do
      @organization = Factory(:organization)
      Factory(:data_request, :organization => @organization)
      @target_org         = Factory(:organization)
      @duplicate_org      = Factory(:organization)
      @target_response    = @target_org.latest_response
      @duplicate_response = @duplicate_org.latest_response

      Factory(:data_request, :organization => @organization)
      @target_response2    = @target_org.latest_response
      @duplicate_response2 = @duplicate_org.latest_response
    end

    it "deletes duplicate after merge" do
      Organization.merge_organizations!(@target_org, @duplicate_org)
      all_organizations = Organization.all
      all_organizations.should include(@target_org)
      all_organizations.should_not include(@duplicate_org)
    end

    it "moves projects from duplicate to target organization" do
      project1 = Factory(:project, :data_response => @duplicate_response)
      project2 = Factory(:project, :data_response => @duplicate_response2)

      Organization.merge_organizations!(@target_org, @duplicate_org)
      all_organizations = Organization.all
      @target_response.projects.should include(project1)
      @target_response2.projects.should include(project2)
      all_organizations.should include(@target_org)
      all_organizations.should_not include(@duplicate_org)
    end

    it "copies also invalid data responses from duplicate to @target" do
      @duplicate_org.fiscal_year_start_date = "2010-02-01"
      @duplicate_org.fiscal_year_end_date = "2010-01-01"
      @duplicate_org.save(false)
      duplicate_data_response = @duplicate_org.latest_response
      Organization.merge_organizations!(@target_org, @duplicate_org)
      @target_org.data_responses.count.should == 2 # not 2, since our before block created a valid DR
    end

    it "moves activities from duplicate to target organization" do
      project1 = Factory(:project, :data_response => @duplicate_response)
      project2 = Factory(:project, :data_response => @duplicate_response2)
      activity1 = Factory(:activity, :data_response => @duplicate_response,
                          :project => project1)
      activity2 = Factory(:activity, :data_response => @duplicate_response2,
                          :project => project2)

      Organization.merge_organizations!(@target_org, @duplicate_org)

      @target_response.activities.should include(activity1)
      @target_response2.activities.should include(activity2)
      activity1.project.should == project1
      activity2.project.should == project2
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

    it "should update users count when user is moved to other organization" do
      o1       = Factory(:organization)
      o2       = Factory(:organization)
      reporter = Factory.create(:reporter, :organization => o1)

      reporter.organization.should == o1
      o1.reload.users_count.should == 1
      o2.reload.users_count.should == 0

      reporter.organization_id = o2.id
      reporter.save!

      reporter.reload.organization.should == o2
      o1.reload.users_count.should == 0
      o2.reload.users_count.should == 1
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

    it "order organizations by name" do
      org1 = Factory(:organization, :name => 'Org2')
      org2 = Factory(:organization, :name => 'Org1')

      Organization.ordered.should == [org2, org1]
    end

    it "returns (non/)reporting organizations" do
      @org1 = Factory(:organization, :raw_type => 'Bilateral')

      non_reporting_types = ['Clinic/Cabinet Medical', 'Communal FOSA',
        'Dispensary', 'District', 'District Hospital', 'Health Center',
        'Health Post', 'Non-Reporting', 'Other ministries',
        'Prison Clinic']
      non_reporting_types.each do |type|
        Factory(:organization, :raw_type => type)
      end

      Organization.reporting.should == [@org1]
      Organization.nonreporting.count.should == non_reporting_types.count
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

  describe "organization types" do
    it "includes 'Non-Reporting' type" do
      Organization::ORGANIZATION_TYPES.should include('Non-Reporting')
    end
  end

  describe "#reporting?" do
    it "is reporting when raw_type is not 'Non-Reporting'" do
      organization = Factory.build(:organization, :raw_type => 'Bilateral')
      organization.reporting?.should be_true
    end
  end

  describe "#nonreporting?" do
    it "is nonreporting when raw_type is 'Non-Reporting'" do
      organization = Factory.build(:organization, :raw_type => 'Non-Reporting')
      organization.nonreporting?.should be_true
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

