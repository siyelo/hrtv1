require File.dirname(__FILE__) + '/../spec_helper'

describe User do

  describe "Attributes" do
    it { should allow_mass_assignment_of(:full_name) }
    it { should allow_mass_assignment_of(:email) }
    it { should allow_mass_assignment_of(:password) }
    it { should allow_mass_assignment_of(:password_confirmation) }
    it { should allow_mass_assignment_of(:organization_id) }
    it { should allow_mass_assignment_of(:organization) }
    it { should allow_mass_assignment_of(:organization_ids) }
    it { should allow_mass_assignment_of(:roles) }
  end

  describe "Associations" do
    it { should have_many :comments }
    it { should have_many :data_responses }
    it { should belong_to :organization }
    it { should belong_to :current_response }
    it { should have_and_belong_to_many :organizations }
  end

  describe "Validations" do
    it { should validate_presence_of(:full_name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:organization_id) }

    context "existing record in db" do
      subject { Factory(:reporter, :organization => Factory(:organization) ) }
      it { should validate_uniqueness_of(:email).case_insensitive }
    end

    it "cannot assign blank role" do
      user = Factory.build(:reporter, :roles => [])
      user.save
      user.errors.on(:roles).should include('is not included in the list')
    end

    it "cannot assign unexisting role" do
      user = Factory.build(:reporter, :roles => ['admin123'])
      user.save
      user.errors.on(:roles).should include('is not included in the list')
    end
  end

  describe "Callbacks" do
    before :each do
      @organization = Factory(:organization)
      @request1 = Factory(:data_request)
      @dr1 = @organization.latest_response
      @request2 = Factory(:data_request)
      @dr2 = @organization.reload.latest_response
    end

    it "assigns current_response to last data_response from the organization" do
      user = Factory.build(:user, :organization => @organization, :current_response => nil)
      user.save
      user.current_response.should == @dr2
    end

    it "does not assign current_response if it already exists" do
      @request3 = Factory(:data_request)
      @dr3 = @organization.latest_response
      user = Factory.build(:user, :organization => @organization, :current_response => @dr3)
      user.save
      user.current_response.should_not == @dr2
    end
  end

  describe "passwords" do
    it "should allow (admin) to create a user w/out a password" do
      pending #TODO - add 'active'
      lambda {Factory(:user, :password => nil, :password_confirmation => nil,
        :active => false)}.should_not raise_error(ActiveRecord::RecordInvalid)
    end

    it "should allow (admin) to update a user before they have registered" do
      pending #TODO - add 'active'
      @user = Factory(:user, :password => nil, :password_confirmation => nil, :active => false)
      @user.full_name = "bob rob"
      @user.save.should == true
    end

    it "should NOT allow (user) to accept invitation (go active) w/out a password" do
      pending #TODO - add 'active'
      @user = Factory(:user, :password => nil, :password_confirmation => nil, :active => false)
      @user.activate.should == false
      @user.errors.on(:password).should == "is too short (minimum is 6 characters)"
    end

    it "should NOT allow (user) to accept invitation (go active) with a short password" do
      pending #seems to be skipping the length validation.
      @user = Factory(:user, :password => nil, :password_confirmation => nil, :active => false)
      @user.password = '123'
      @user.password_confirmation = '123'
      @user.activate.should == false
      @user.errors.on(:password).should == "too short!"
    end

    it "should allow (user) to accept invitation (go active) with a good password" do
      pending #TODO - add 'active'
      @user = Factory(:user, :password => nil, :password_confirmation => nil, :active => false)
      @user.password = '123456'
      @user.password_confirmation = '123456'
      @user.activate.should == true
    end

    it "should allow (user) to update w/out a password" do
      pending #TODO - add 'active'
      @user = Factory(:user, :password => 'abcdef', :password_confirmation => 'abcdef', :active => true)
      @user.full_name = "bob rob"
      @user.save.should == true
    end
  end

  describe "roles" do
    it "is sysadmin when has admin role" do
      user = Factory(:user, :roles => ['admin'])
      user.sysadmin?.should be_true
    end

    it "is reporter when has reporter role" do
      user = Factory(:user, :roles => ['reporter'])
      user.reporter?.should be_true
    end

    it "is activity_manager when has activity_manager role" do
      user = Factory(:user, :roles => ['activity_manager'])
      user.activity_manager?.should be_true
    end

    it "is district_manager when has district_manager role" do
      user = Factory(:user, :roles => ['district_manager'])
      user.district_manager?.should be_true
    end

    it "is admin when roles_mask = 1" do
      user = Factory(:user, :roles => ['admin'])
      user.roles.should == ['admin']
      user.roles_mask.should == 1
    end

    it "is reporter when roles_mask = 2" do
      user = Factory(:user, :roles => ['reporter'])
      user.roles.should == ['reporter']
      user.roles_mask.should == 2
    end

    it "is admin and reporter when roles_mask = 3" do
      user = Factory(:user, :roles => ['admin', 'reporter'])
      user.roles.should == ['admin', 'reporter']
      user.roles_mask.should == 3
    end

    it "is activity_manager when roles_mask = 4" do
      user = Factory(:user, :roles => ['activity_manager'])
      user.roles.should == ['activity_manager']
      user.roles_mask.should == 4
    end

    it "is admin and activity_manager when roles_mask = 5" do
      user = Factory(:user, :roles => ['admin', 'activity_manager'])
      user.roles.should == ['admin', 'activity_manager']
      user.roles_mask.should == 5
    end

    it "is reporter and activity_manager when roles_mask = 6" do
      user = Factory(:user, :roles => ['reporter', 'activity_manager'])
      user.roles.should == ['reporter', 'activity_manager']
      user.roles_mask.should == 6
    end

    it "is admin, reporter and activity_manager when roles_mask = 7" do
      user = Factory(:user, :roles => ['admin', 'reporter', 'activity_manager'])
      user.roles.should == ['admin', 'reporter', 'activity_manager']
      user.roles_mask.should == 7
    end

    it "is district_manager when roles_mask = 8" do
      user = Factory(:user, :roles => ['district_manager'])
      user.roles.should == ['district_manager']
      user.roles_mask.should == 8
    end

    it "is admin & district_manager when roles_mask = 9" do
      user = Factory(:user, :roles => ['admin', 'district_manager'])
      user.roles.should == ['admin', 'district_manager']
      user.roles_mask.should == 9
    end

    it "is reporter & district_manager when roles_mask = 10" do
      user = Factory(:user, :roles => ['reporter', 'district_manager'])
      user.roles.should == ['reporter', 'district_manager']
      user.roles_mask.should == 10
    end

    it "is admin, reporter & district_manager when roles_mask = 11" do
      user = Factory(:user, :roles => ['admin', 'reporter', 'district_manager'])
      user.roles.should == ['admin', 'reporter', 'district_manager']
      user.roles_mask.should == 11
    end

    it "is admin, reporter & district_manager when roles_mask = 12" do
      user = Factory(:user, :roles => ['activity_manager', 'district_manager'])
      user.roles.should == ['activity_manager', 'district_manager']
      user.roles_mask.should == 12
    end

    it "is admin, activity_manager & district_manager when roles_mask = 13" do
      user = Factory(:user, :roles => ['admin', 'activity_manager', 'district_manager'])
      user.roles.should == ['admin', 'activity_manager', 'district_manager']
      user.roles_mask.should == 13
    end

    it "is reporter, activity_manager & district_manager when roles_mask = 14" do
      user = Factory(:user, :roles => ['reporter', 'activity_manager', 'district_manager'])
      user.roles.should == ['reporter', 'activity_manager', 'district_manager']
      user.roles_mask.should == 14
    end

    it "is admin, reporter, activity_manager & district_manager when roles_mask = 15" do
      user = Factory(:user, :roles => ['admin', 'reporter', 'activity_manager', 'district_manager'])
      user.roles.should == ['admin', 'reporter', 'activity_manager', 'district_manager']
      user.roles_mask.should == 15
    end
  end

  describe "roles= can be assigned" do
    it "can assign 1 role" do
      user = Factory(:reporter)
      user.roles = ['admin']
      user.save
      user.reload.roles.should == ['admin']
    end

    it "can assign 3 roles" do
      user = Factory(:reporter)
      user.roles = ['admin', 'reporter', 'activity_manager']
      user.save
      user.reload.roles.should == ['admin', 'reporter', 'activity_manager']
    end
  end

  describe "role change" do
    it "removed organizations when role is changed from activity_manager to else" do
      org1 = Factory(:organization)
      org2 = Factory(:organization)
      user = Factory(:activity_manager, :organizations => [org1, org2])
      user.roles = ['reporter']
      user.save
      user.organizations.should be_empty
    end
  end

  describe "current response/request" do
    before :each do
      @org      = Factory(:organization)
      @request  = Factory(:data_request)
      @response = @org.latest_response
      @user = Factory(:reporter, :current_response => @response, :organization => @org)
    end

    it "returns the associated request" do
      @user.current_request.should == @response.request
    end
  end
end
