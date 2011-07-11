require File.dirname(__FILE__) + '/../spec_helper'

describe User do

  describe "attributes" do
    it { should allow_mass_assignment_of(:full_name) }
    it { should allow_mass_assignment_of(:email) }
    it { should allow_mass_assignment_of(:password) }
    it { should allow_mass_assignment_of(:password_confirmation) }
    it { should allow_mass_assignment_of(:organization_id) }
    it { should allow_mass_assignment_of(:organization) }
    it { should allow_mass_assignment_of(:organization_ids) }
    it { should allow_mass_assignment_of(:roles) }
  end

  describe "associations" do
    it { should have_many :comments }
    it { should have_many :data_responses }
    it { should belong_to :organization }
    it { should belong_to :current_response }
    it { should have_and_belong_to_many :organizations }
  end

  describe "Validations" do
    subject { Factory(:reporter, :organization => Factory(:organization) ) }
    it { should be_valid }
    it { should validate_presence_of(:full_name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:organization_id) }
    it { should validate_uniqueness_of(:email).case_insensitive }

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
      @dr1 = Factory(:data_response)
      @dr2 = Factory(:data_response)
      @organization = Factory(:organization, :data_responses => [@dr1, @dr2])
    end

    it "assigns current_response to last data_response from the organization" do
      user = Factory.build(:user, :organization => @organization, :current_response => nil)
      user.save
      user.current_response.should == @dr2
    end

    it "does not assign current_response if it already exists" do
      dr   = Factory(:data_response)
      user = Factory.build(:user, :organization => @organization, :current_response => dr)
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
      @org = Factory :organization
      @response = Factory(:response, :organization => @org)
      @user = Factory(:reporter, :current_response => @response, :organization => @org)
    end

    it "returns the associated request" do
      @user.current_request.should == @response.request
    end
  end
end
