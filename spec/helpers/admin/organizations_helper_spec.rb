require 'spec_helper'
include OrganizationsHelper

describe Admin::OrganizationsHelper do
  describe "#return_organization_response" do
    it "should return the correct response for the organization" do
      basic_setup_response
      OrganizationsHelper.organization_response(@organization).should == @response
    end

    it "should return the correct response for the organization" do
      basic_setup_response
      org = Factory(:organization)
      req = Factory(:data_request)
      dr1 = org.latest_response
      OrganizationsHelper.organization_response(org).should_not == @response
    end
  end

  describe "#organization_activity_managers" do
    before :each do
      @organization = Factory(:organization)
    end

    it "should only return activity managers from the organization passed to it" do
      u1 = Factory(:reporter, :organization => @organization)
      u2 = Factory(:sysadmin, :organization => @organization)
      u3 = Factory(:activity_manager, :organization => @organization)
      u3.organizations << @organization
      OrganizationsHelper.organization_activity_managers(@organization).should include(u3)
      OrganizationsHelper.organization_activity_managers(@organization).should_not include(u1)
      OrganizationsHelper.organization_activity_managers(@organization).should_not include(u2)
    end

    it "should return all activity managers from the organization passed to it" do
      u1 = Factory(:reporter, :organization => @organization)
      u2 = Factory(:sysadmin, :organization => @organization)
      u3 = Factory(:activity_manager, :organization => @organization)
      u4 = Factory(:activity_manager, :organization => @organization)
      u3.organizations << @organization; u4.organizations << @organization
      OrganizationsHelper.organization_activity_managers(@organization).should include(u3)
      OrganizationsHelper.organization_activity_managers(@organization).should include(u4)
      OrganizationsHelper.organization_activity_managers(@organization).should_not include(u1)
      OrganizationsHelper.organization_activity_managers(@organization).should_not include(u2)
    end

    it "should return activity managers that are able to manage the organization even if they aren't part of it" do
      org = Factory(:organization)
      u1 = Factory(:reporter, :organization => @organization)
      u2 = Factory(:sysadmin, :organization => @organization)
      u3 = Factory(:activity_manager, :organization => org)
      u3.organizations << @organization
      OrganizationsHelper.organization_activity_managers(@organization).should include(u3)
      OrganizationsHelper.organization_activity_managers(@organization).should_not include(u1)
      OrganizationsHelper.organization_activity_managers(@organization).should_not include(u2)
    end

  end
end
