require File.dirname(__FILE__) + '/../../spec_helper'

describe User, "District Managers" do
  it "should not allow you to create a DM without a location" do
    @dm = Factory.build(:district_manager, :location_id => nil)
    @dm.valid?.should be_false
  end

  it "should allow you to create a DM with a location" do
    @location = Factory(:location)
    @dm = Factory.build(:district_manager, :location => @location)
    @dm.valid?.should be_true
  end

  it "should not allow you to create a DM with a reporting organization" do
    @org = Factory(:reporting_organization)
    @dm = Factory.build(:district_manager, :organization => @org)
    @dm.valid?.should be_false
  end

  it "should allow you to create a DM with a non-reporting organization" do
    @org = Factory(:nonreporting_organization)
    @dm = Factory.build(:district_manager, :organization => @org)
    @dm.valid?.should be_true
  end

  it "should remove the location id if a DM is removed from a users roles" do
    @org = Factory(:reporting_organization)
    @user = Factory(:district_manager)
    @user.organization_id = @org.id; @user.roles = ['reporter']; @user.save; @user.reload #need to set organization because reporters require organizations
    @user.location_id.should be_nil
    @user.location.should be_nil
  end

  it "should remove the organization id if activity_manager is removed from a users role" do
    @user = Factory(:activity_manager)
    @user.roles = ['reporter']; @user.save; @user.reload
    @user.organizations.should be_empty
  end
end