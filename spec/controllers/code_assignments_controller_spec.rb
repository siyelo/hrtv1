require 'spec_helper'

describe "Routing shortcuts for Code Assignments (activities/1/coding) should map" do
  controller_name :code_assignments

  before(:each) do
    @activity = Factory.create(:activity)
    #@activity.stub!(:to_param).and_return('1')
    #@coding.stub!(:find).and_return(@code_assignment)
  end
  
  it "budget_activity_coding to activities/:id/coding/budget" do
    get :budget, :activity_id => "1"
    budget_activity_coding_path.should == '/activities/1/coding/budget'
  end 
  
  it "expenditure_activity_coding to activities/:id/coding/expenditure" do
    get :expenditure, :activity_id => "1"
    expenditure_activity_coding_path.should == '/activities/1/coding/expenditure'
  end
  
  it "update coding activities/:id/coding/update" do
    pending
  end
end


describe "Requesting Coding endpoints as visitor" do
  controller_name :code_assignments
  
  before :each do
    @activity = Factory.create(:activity)
  end
  
  context "Requesting activities/:id/coding/budget using GET" do
    before do get :budget, :activity_id => "1" end
    it_should_behave_like "a protected endpoint"
  end

  context "Requesting activities/:id/coding/expenditure using GET" do
    before do get :expenditure, :activity_id => "1" end
    it_should_behave_like "a protected endpoint"
  end
  
  context "Requesting activities/:id/coding/update using POST" do
    it "should be protected" do pending end
  end
  
end

describe "Requesting Coding endpoints as reporter" do
  controller_name :code_assignments
  
  before :each do
    @user = Factory.create(:reporter)
    login @user
    @activity = Factory.create(:activity)
    @codes = ['codes']
  end
  
  context "Requesting activities/:id/coding/budget using GET" do
    it "should find the activity" do
      Activity.should_receive(:find).with("1").and_return(@activity)
      get :budget, :activity_id => 1
    end
    
    it "should find the relevant codes " do
      pending
      #@activity.should_receive(:valid_roots_for_code_assignment).and_return(@codes)
      #get :budget, :activity_id => 1
    end
    
    context "on successful request" do
      before :each do
        get :budget, :activity_id => 1
      end
  
      it { should assign_to(:activity) }
      it { should assign_to(:codes) }
      it { should respond_with(:success) }
      it { should render_template(:budget) }
      it { should_not set_the_flash }
    end
  end  
  
  context "Requesting activities/:id/coding/expenditure using GET" do
    it "should find the activity" do
      Activity.should_receive(:find).with("1").and_return(@activity)
      get :expenditure, :activity_id => 1
    end
    
    context "on successful request" do
      before :each do
        get :expenditure, :activity_id => 1
      end
  
      it { should assign_to(:activity) }
      it { should assign_to(:codes) }
      it { should respond_with(:success) }
      it { should render_template(:expenditure) }
      it { should_not set_the_flash }
    end
  end
  
  context "Requesting activities/:id/update_coding_budget using POST" do
     it "should find the activity" do
       Activity.should_receive(:find).with(@activity.id.to_s).and_return(@activity)
       post :update_budget, :activity_id => @activity.id, 
                            :activity => { :code_assignment_tree => ["1"], 
                                           :budget_amounts => { "1" => "10" }}
     end
     
     context "on successful request" do
       before :each do
         post :update_budget, :activity_id => @activity.id, 
                              :activity => { :code_assignment_tree => ["1"], 
                                             :budget_amounts => { "1" => "10"}}
       end
   
       it { should redirect_to(budget_activity_coding_path(@activity)) }
     end
   end 
   
   context "Requesting activities/:id/update_coding_expenditure using POST" do
     it "should find the activity" do
       Activity.should_receive(:find).with(@activity.id.to_s).and_return(@activity)
       post :update_expenditure, :activity_id => @activity.id, 
                                 :activity => { :code_assignment_tree => ["1"], 
                                                :expenditure_amounts => { "1" => "10" }}
     end
     
     context "on successful request" do
       before :each do
         post :update_expenditure,  :activity_id => @activity.id, 
                                    :activity => { :code_assignment_tree => ["1"], 
                                                   :expenditure_amounts => { "1" => "10"}}
       end
   
       it { should redirect_to(expenditure_activity_coding_path(@activity)) }
     end
   end
  
  
end