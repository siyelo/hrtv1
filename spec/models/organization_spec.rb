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
end
