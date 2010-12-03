require File.dirname(__FILE__) + '/../spec_helper'

describe Project do
  
  describe "creating a project record" do
    subject { Factory(:project) }
    it { should be_valid }
    it { should have_and_belong_to_many :activities }
    it { should have_and_belong_to_many :locations }
    it { should have_many :funding_flows }
    it { should have_many :in_flows }
    it { should have_many :out_flows }
    it { should have_many :comments }
    it { should have_many :funding_sources }
    it { should have_many :providers }
    it { should have_and_belong_to_many :locations }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:data_response_id) }
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
    
    it "should have a valid data_response " do
      project = Factory(:project)
      project.data_response.should_not be_nil
    end
    
    it "should return the owning organization " do
      project = Factory(:project)
      lambda {project.organization}.should_not raise_error
    end
      
    it " should NOT create workflow records after save" do
      proj  = Factory.create(:project)
      proj.funding_flows.should have(0).items
    end
  end
  
  context "Funding flows: " do
    before(:each) do
      @our_org       = Factory(:organization)
      @data_response = Factory(:data_response, 
                                :responding_organization => @our_org)
      @other_org     = Factory(:organization)
      @project       = Factory(:project, 
                                :data_response => @data_response )
    end

    it "assigns and returns a sole funding source" do  
      flow      = Factory(:funding_flow, 
                          :from          => @other_org, 
                          :to            => @our_org,
                          :project       => @project,
                          :data_response => @project.data_response)
      @project.reload
      @project.in_flows.first.should == flow
      @project.funding_sources.first.should == @other_org
    end
  
    it "assigns and returns a sole implementer" do
      flow         = Factory(:funding_flow, 
                            :from          => @our_org, 
                            :to            => @other_org,
                            :project       => @project,
                            :data_response => @project.data_response)

      @project.reload
      @project.out_flows.first.should == flow
      @project.implementers.first.should == @other_org  
      @project.providers.first.should == @other_org     #GR: deprecate me! 
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

  context "on delete" do
    it "should nullify funding flows on delete" do
      project = Factory(:project)
      flow    = Factory(:funding_flow, 
                        :organization_id_from => project.organization, 
                        :project => project,
                        :data_response => project.data_response)                      
      f = project.funding_flows.first
      project.destroy
      f.reload
      f.project.should == nil
    end
  end
  
  describe "counter cache" do
    context "comments cache" do
      before :each do
        @commentable = Factory.create(:project)
      end

      it_should_behave_like "comments_cacher"
    end
  end
  
  describe "deep cloning" do
    before :each do
      @project = Factory(:project)
      @original = @project #for shared examples
      @a1 = Factory(:activity, 
                     :data_response => @project.data_response,
                     :projects => [@project])
      @a2 = Factory(:activity, 
                     :data_response => @project.data_response,
                     :projects => [@project])
      save_and_deep_clone
    end
    
    it "should clone associated activities" do
      @clone.activities.count.should == 2
      @clone.activities.first.projects.count.should == 2 # old project HABTM reference on the cloned activity
    end
    
    it "should have the correct number of activities after the original project is destroyed" do
      @project.destroy
      @clone.reload
      @clone.activities.count.should == 2
      @clone.activities.first.projects.count.should == 1
    end
    
    it_should_behave_like "location cloner"
    
  end

end
