require File.dirname(__FILE__) + '/../spec_helper'

describe Project do
  
  describe "creating a project record" do
    subject { Factory(:project) }
    it { should be_valid }
    it { should have_and_belong_to_many :activities }
    it { should have_many :funding_flows }
    it { should have_many :comments }
    it { should have_and_belong_to_many :locations }
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
  
    it "should remove commas from decimal fields on save" do
      [:spend, :budget, :entire_budget].each do |f|
        p = Project.new
        p.send(f.to_s+"=", "10,783,000.32")
        p.save
        p.send(f).should == 10783000.32
      end
    end
    
    it " should create workflow records after save" do
      data_request  = Factory.create(:data_request)      
      org   = Factory.create(:organization)
      data_response = Factory.create(:data_response, 
                                      :data_request => data_request,
                                      :responding_organization => org)
      user  = Factory.create(:user, :organization => org, :data_response_id_current => data_response)
      proj  = Factory.create(:project, :data_response => data_response)
      proj.funding_flows.should have(2).items
      to_me = nil
      from_me_to_me = nil
      proj.funding_flows.each do |ff|
        if ff.to == proj.owner
          if ff.from == proj.owner && ff.self_provider_flag == 1
            from_me_to_me = ff
          else
            to_me = ff
          end
        end
      end
      to_me.should_not == nil
      from_me_to_me.should_not == nil
      
      [:budget, :spend, :spend_q4_prev, :spend_q1, :spend_q2, :spend_q3, :spend_q4, :data_response].each do |att|
        to_me.send(att).should == proj.send(att)
        from_me_to_me.send(att).should == proj.send(att)
      end
    end
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
                    :budget =>        800 )
      dr.should be_valid
    end
    
    it "accepts Total Budget = Total Budget GOR" do
      dr = Factory.build(:project, 
                    :start_date => DateTime.new(2010, 01, 01),
                    :end_date =>   DateTime.new(2010, 01, 02),
                    :entire_budget => 900,
                    :budget =>        900 )
      dr.should be_valid
    end
    
    it "does not accept Total Budget < Total Budget GOR" do
      dr = Factory.build(:project, 
                    :start_date => DateTime.new(2010, 01, 01),
                    :end_date =>   DateTime.new(2010, 01, 02),
                    :entire_budget => 900,
                    :budget =>        1000 )
      dr.should_not be_valid
    end
  end
  
  # this test belongs in cuke or controller specs. 
  describe "can't see projects not in my data response" do
    it 'should not allow others to see my projects' do
      pending
      #data_request  = Factory.create(:data_request)      
      #org   = Factory.create(:organization)
      #data_response = Factory.create(:data_response, 
#                                      :data_request => data_request,
#                                      :responding_organization => org)
      #user  = Factory.create(:user, :organization => org, :data_response_id_current => data_response)
      #user2 = Factory.create(:user)
      #proj  = Factory.create(:project, :data_response => data_response)
      #Project.available_to(user).first.should == proj
      #Project.available_to(user2).count == 0
    end 
  end
  
  describe "on delete"
   it "nullifies funding flows on delete" do
    p = Factory.create(:project)
    c = p.funding_flows.first
    p.destroy
    c.reload
    c.project.should == nil
  end
  
end
