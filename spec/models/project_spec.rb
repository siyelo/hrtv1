require File.dirname(__FILE__) + '/../spec_helper'

describe Project do
 context "a user is logged in" do
    before(:each) do
      @current_user      = Factory(:user)
    end

    describe "creating a project record" do
      subject { Factory(:project) }
      
      it { should be_valid }
      it { should validate_presence_of(:name) }
  #    it { should validate_presence_of(:description) }
  #    it { should validate_presence_of(:expected_total) }
      it { should allow_value(123.45).for(:expected_total) }
      it { should_not allow_value("blah").for(:expected_total) }
    end
    
    describe "assigning funding flows" do
      it "should have no assigned funding flows on creation" do
        project = Factory(:project)
        project.funding_flows.should be_empty
      end
    
      it "should assign a valid funding flow" do
        project = Factory(:project) 
        flow    = Factory(:funding_flow, :from => Factory(:organization), :to => Factory(:organization))
        project.funding_flows << flow
        project.funding_flows.should have(1).item
      end
    end
    
    context "funding sources and outflows" do
      before(:each) do
        @our_org      = Factory(:organization)
        @other_org    = Factory(:organization)
        @project      = Factory(:project)
      end

      describe "getting who provided money to us (funding sources)" do
        it "should return a sole funding source" do  
          flow      = Factory(:funding_flow, :from => @other_org, :to => @our_org)
          @project.funding_flows << flow
          @project.funding_sources.should have(1).item
          @project.funding_sources.first.should == @other_org
        end    
      end
    
      describe "getting who we gave money to (the 'providers' we gave to)" do
        it "should return a sole organization" do
          flow         = Factory(:funding_flow, :from => @our_org, :to => @other_org)
          @project.funding_flows << flow
          # GR: 'providers' doesnt make a lot of sense from this perspective - our domain model a bit off?
          @project.providers.should have(1).item
          @project.providers.first.should == @other_org
        end

        it "should return a sole organization we sent money to via the flows API" do
          flow         = Factory(:funding_flow, :from => @our_org, :to => @other_org, :project => @project)
          @project.providers.first.should == @other_org
        end
      end
    end
 end

end
