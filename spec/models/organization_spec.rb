require File.dirname(__FILE__) + '/../spec_helper'

describe Organization do
  
  describe "creating a organization record" do
    subject { Factory(:organization) }
    
    it { should be_valid }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    
    it "can have many in_flows" do
      subject.in_flows.should have(0).items
      Factory.create(:funding_flow, :to => subject)
      subject.reload
      subject.in_flows.should have(1).item
    end    
    
    it "can have many out_flows" do
      subject.out_flows.should have(0).items
      Factory.create(:funding_flow, :from => subject)
      subject.reload
      subject.out_flows.should have(1).item
    end
    
    it "can donate to a project" do
      subject.donor_for.should have(0).items
      project = Factory.create(:project)
      Factory.create(:funding_flow, :from => subject, :project => Factory.create(:project))
      subject.reload
      subject.donor_for.should have(1).item
    end
    
    it "can implement a project" do
      subject.implementor_for.should have(0).items
      project = Factory.create(:project)
      Factory.create(:funding_flow, :to => subject, :project => project)
      subject.reload
      subject.implementor_for.should have(1).item

      subject.implementor_for.first.should == project
    end    
  end  

  describe "remove duplicate organization" do
    it "deletes duplicate after merge" do
      target = Factory.create(:organization)
      duplicate = Factory.create(:organization)

      Organization.merge_organizations!(target, duplicate)

      all_organizations = Organization.all
      all_organizations.should include(target)
      all_organizations.should_not include(duplicate)
    end

    it "copies activities from duplicate to target" do
      target = Factory.create(:organization)
      target.activities << Factory.create(:activity)
      duplicate = Factory.create(:organization)
      duplicate.activities << Factory.create(:activity)

      Organization.merge_organizations!(target, duplicate)

      target.activities.count.should == 2
    end

    it "copies data_requests_made from duplicate to target" do
      target = Factory.create(:organization)
      Factory.create(:data_request, :requesting_organization => target)
      duplicate = Factory.create(:organization)
      Factory.create(:data_request, :requesting_organization => duplicate)

      Organization.merge_organizations!(target, duplicate)

      target.data_requests_made.count.should == 2
    end

    it "copies data responses from duplicate to target" do
      target = Factory.create(:organization)
      Factory.create(:data_response, :responding_organization => target)
      duplicate = Factory.create(:organization)
      Factory.create(:data_response, :responding_organization => duplicate)

      Organization.merge_organizations!(target, duplicate)

      target.data_responses.count.should == 2
    end


    it "copies out flows from duplicate to target" do
      target = Factory.create(:organization)
      target.out_flows << Factory.create(:funding_flow)
      duplicate = Factory.create(:organization)
      duplicate.out_flows << Factory.create(:funding_flow)

      Organization.merge_organizations!(target, duplicate)

      target.out_flows.count.should == 2
    end

    it "copies in flows from duplicate to target" do
      target = Factory.create(:organization)
      target.in_flows << Factory.create(:funding_flow)
      duplicate = Factory.create(:organization)
      duplicate.in_flows << Factory.create(:funding_flow)

      Organization.merge_organizations!(target, duplicate)

      target.in_flows.count.should == 2
    end

    it "copies locations from duplicate to target" do
      target = Factory.create(:organization)
      target.locations << Factory.create(:location)
      duplicate = Factory.create(:organization)
      duplicate.locations << Factory.create(:location)

      Organization.merge_organizations!(target, duplicate)

      target.locations.count.should == 2
    end

    it "copies users from duplicate to target" do
      target = Factory.create(:organization)
      Factory.create(:user, :organization => target)
      duplicate = Factory.create(:organization)
      Factory.create(:user, :organization => duplicate)

      Organization.merge_organizations!(target, duplicate)

      target.users.count.should == 2
    end
  end
end
