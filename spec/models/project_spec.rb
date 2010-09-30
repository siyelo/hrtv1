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
      it { should allow_value(123.45).for(:budget) }
      it { should allow_value(123.45).for(:spend) }
      it { should allow_value(123.45).for(:entire_budget) }
      it { should allow_value('2010-12-01').for(:start_date) }
      it { should allow_value('2010-12-01').for(:end_date) }
      it { should_not allow_value('').for(:start_date) }
      it { should_not allow_value('').for(:end_date) }
      it { should_not allow_value('2010-13-01').for(:start_date) }
      it { should_not allow_value('2010-12-41').for(:start_date) }
      it { should_not allow_value('2010-13-01').for(:end_date) }
      it { should_not allow_value('2010-12-41').for(:end_date) }
    end
    
    describe "assigning funding flows" do
      it "should have no assigned funding flows on creation" do
        pending  # see http://www.pivotaltracker.com/story/show/4925498
        project = Factory(:project)
        project.funding_flows.should be_empty
      end
    
      it "should assign a valid funding flow" do
        pending # see http://www.pivotaltracker.com/story/show/4925498
        project = Factory(:project) 
        flow    = Factory(:funding_flow, :from => Factory(:organization), :to => Factory(:organization))
        project.funding_flows << flow
        project.funding_flows.should have(1).item
      end
    end
    
    context "commentable" do
      describe "commenting on a project" do
        it "should assign to a project" do
          project     = Factory(:project)
          comment     = Factory(:comment)
          project.comments << comment
          project.comments.should have(1).item
          project.comments.first.should == comment
        end
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
  
  describe "multi-field validations" do
    it "accepts start date < end date" do
      dr = Factory.build(:project, 
                    :start_date => DateTime.new(2010, 01, 01),
                    :end_date =>   DateTime.new(2010, 01, 02) )
      dr.should be_valid
    end

    it "does not accept start date > end date" do
      dr = Factory.build(:project, 
                    :start_date => DateTime.new(2010, 01, 02),
                    :end_date =>   DateTime.new(2010, 01, 01) )
      dr.should_not be_valid
    end

    it "does not accept start date = end date" do
      dr = Factory.build(:project, 
                    :start_date => DateTime.new(2010, 01, 01),
                    :end_date =>   DateTime.new(2010, 01, 01) )
      dr.should_not be_valid
    end
    
    it "accepts Total Budget >= Total Budget GOR" do
      dr = Factory.build(:project, 
                    :start_date => DateTime.new(2010, 01, 01),
                    :end_date =>   DateTime.new(2010, 01, 02),
                    :entire_budget => 900,
                    :budget =>        800
                    )
      dr.should be_valid
    end
    
    it "accepts Total Budget = Total Budget GOR" do
      dr = Factory.build(:project, 
                    :start_date => DateTime.new(2010, 01, 01),
                    :end_date =>   DateTime.new(2010, 01, 02),
                    :entire_budget => 900,
                    :budget =>        900
                    )
      dr.should be_valid
    end
    
    it "does not accept Total Budget < Total Budget GOR" do
      dr = Factory.build(:project, 
                    :start_date => DateTime.new(2010, 01, 01),
                    :end_date =>   DateTime.new(2010, 01, 02),
                    :entire_budget => 900,
                    :budget =>        1000
                    )
      dr.should_not be_valid
    end
    
  end
  
end
