require 'spec_helper'
include OrganizationsHelper

describe Admin::OrganizationsHelper do
  describe "#return_organization_response" do
    it "should return the correct response for the organization" do
      basic_setup_response
      OrganizationsHelper.organization_response(@organization, @request).should == @response
    end

    it "should return the correct response for the organization" do
      basic_setup_response
      org = Factory(:organization)
      req = Factory(:data_request)
      dr1 = org.latest_response
      OrganizationsHelper.organization_response(org, req).should_not == @response
    end
  end
end
