require File.dirname(__FILE__) + '/../spec_helper'

describe User do

  describe "attributes" do
    it { should allow_mass_assignment_of(:full_name) }
    it { should allow_mass_assignment_of(:email) }
    it { should allow_mass_assignment_of(:username) }
    it { should allow_mass_assignment_of(:password) }
    it { should allow_mass_assignment_of(:password_confirmation) }
    it { should allow_mass_assignment_of(:organization_id) }
    it { should allow_mass_assignment_of(:organization) }
    it { should allow_mass_assignment_of(:roles) }
  end

  describe "associations" do
    it { should have_many :comments }
    it { should have_many :data_responses }
    it { should belong_to :organization }
    it { should belong_to :current_data_response }
  end

  describe "validations" do
    subject { Factory(:user, :organization => Factory(:organization) ) }
    it { should be_valid }
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:organization_id) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_uniqueness_of(:username).case_insensitive }
  end

  describe "find_by_username_or_email" do
    it "finds user by username" do
      user = Factory(:user, :username => 'pink.panter')
      User.find_by_username_or_email('pink.panter').should == user
    end

    it "finds user by email" do
      user = Factory(:user, :email => 'pink.panter@gmail.com')
      User.find_by_username_or_email('pink.panter@gmail.com').should == user
    end
  end

  describe "a user can change their current data response" do
    it "it will allow a data response that they have access to" do
      @org = Factory(:organization)
      @user = Factory(:user, :organization => @org)
      @data_response = Factory(:data_response, :organization => @user.organization)
      @user.change_data_response(@data_response.id).should be_true
    end
    
    it "will not allow a user to change to a data request that they dont' have access to (ie. doesn't show up for @user.data_responses)" do
      @org = Factory(:organization)
      @user = Factory(:user, :organization => @org)
      @data_response = Factory(:data_response, :organization => @user.organization)
      @data_response2 = Factory(:data_response)
      @user.change_data_response(@data_response2.id).should be_false
    end
  end
  
  describe "roles" do
    it "is admin when roles_mask = 1" do
      user = Factory(:user, :roles_mask => 1)
      user.roles.should == ['admin']
    end

    it "is reporter when roles_mask = 2" do
      user = Factory(:user, :roles_mask => 2)
      user.roles.should == ['reporter']
    end

    it "is admin and reporter when roles_mask = 3" do
      user = Factory(:user, :roles_mask => 3)
      user.roles.should == ['admin', 'reporter']
    end

    it "is activity_manager when roles_mask = 4" do
      user = Factory(:user, :roles_mask => 4)
      user.roles.should == ['activity_manager']
    end

    it "is admin and activity_manager when roles_mask = 5" do
      user = Factory(:user, :roles_mask => 5)
      user.roles.should == ['admin', 'activity_manager']
    end

    it "is reporter and activity_manager when roles_mask = 6" do
      user = Factory(:user, :roles_mask => 6)
      user.roles.should == ['reporter', 'activity_manager']
    end

    it "is admin, reporter and activity_manager when roles_mask = 7" do
      user = Factory(:user, :roles_mask => 7)
      user.roles.should == ['admin', 'reporter', 'activity_manager']
    end
  end

  describe "roles= can be assigned" do
    it "can assign 1 role" do
      user = Factory(:user)
      user.roles = ['admin']
      user.save
      user.reload.roles.should == ['admin']
    end

    it "can assign 3 roles" do
      user = Factory(:user)
      user.roles = ['admin', 'reporter', 'activity_manager']
      user.save
      user.reload.roles.should == ['admin', 'reporter', 'activity_manager']
    end
    
    it "cannot assign unexisting role" do
      user = Factory(:user)
      user.roles = ['admin123']
      user.save
      user.reload.roles.should == []
    end
  end

  describe "admin?" do
    it "is admin when roles_mask is 1" do
      user = Factory(:user, :roles_mask => 1)
      user.admin?.should be_true
    end

    it "is not admin when roles_mask is not 1" do
      user = Factory(:user, :roles_mask => 2)
      user.admin?.should be_false
    end
  end

  describe "reporter?" do
    it "is reporter when roles_mask is 2" do
      user = Factory(:user, :roles_mask => 2)
      user.reporter?.should be_true
    end

    it "is not reporter when roles_mask is not 1" do
      user = Factory(:user, :roles_mask => 1)
      user.reporter?.should be_false
    end
  end

  describe "activity_manager?" do
    it "is activity_manager when roles_mask is 3" do
      user = Factory(:user, :roles_mask => 3)
      user.reporter?.should be_true
    end

    it "is not activity_manager when roles_mask is not 3" do
      user = Factory(:user, :roles_mask => 1)
      user.reporter?.should be_false
    end
  end

  describe "name" do
    it "returns full_name if full name is present" do
      user = Factory(:user, :full_name => "Pink Panter")
      user.name.should == "Pink Panter"
    end

    it "returns username if full name is nil" do
      user = Factory(:user, :full_name => nil, :username => 'pink.panter')
      user.name.should == "pink.panter"
    end

    it "returns username if full name is blank string" do
      user = Factory(:user, :full_name => '', :username => 'pink.panter')
      user.name.should == "pink.panter"
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                       :integer         primary key
#  username                 :string(255)
#  email                    :string(255)
#  crypted_password         :string(255)
#  password_salt            :string(255)
#  persistence_token        :string(255)
#  created_at               :timestamp
#  updated_at               :timestamp
#  roles_mask               :integer
#  organization_id          :integer
#  data_response_id_current :integer
#  text_for_organization    :text
#  full_name                :string(255)
#  perishable_token         :string(255)     default(""), not null
#

