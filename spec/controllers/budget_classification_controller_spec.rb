require 'spec_helper'

describe "Routing shortcuts for Budget Classification (activities/1/classification/budget) should map" do
  controller_name :budget_classification

  it "activity_budget to activities/:id/classification/budget" do
    @activity = Factory.create(:activity)
    get :show, :activity_id => "1"
    activity_budget_path.should == '/activities/1/classification/budget'
  end
end

describe "Requesting Coding endpoints as visitor" do
  controller_name :budget_classification
  
  before :each do
    @activity = Factory.create(:activity)
  end
  
  context "Requesting activities/:id/classification/budget using GET" do
    before do get :show, :activity_id => "1" end
    it_should_behave_like "a protected endpoint"
  end  
  
  context "Requesting activities/:id/classification/budget using POST" do
    before do do_post("1000") end
    it_should_behave_like "a protected endpoint"
  end
end

describe "Requesting Coding endpoints as reporter" do
  controller_name :budget_classification
  
  before :each do
    @user = Factory.create(:reporter)
    login @user
    @activity = Factory.create(:activity)
    @codes = ['codes']
  end
  
  context "Requesting activities/:id/classification/budget using GET" do
    it "should find the activity" do
      Activity.should_receive(:find).with("1").and_return(@activity)
      get :show, :activity_id => 1
    end
    
    context "on successful request" do
      before :each do get :show, :activity_id => 1 end
      it { should assign_to(:activity) }
      it { should assign_to(:codes) }
      it { should respond_with(:success) }
      it { should render_template(:show) }
      it { should_not set_the_flash }
    end
  end
  
  context "Requesting activities/:id/classification/budget using POST" do
    it "should find the activity" do
      Activity.should_receive(:find).with(@activity.id.to_s).and_return(@activity)
      do_post
    end
    
    context "update amount on successful request" do
      before :each do do_post end
      it { should redirect_to(activity_budget_path(@activity)) }
      it { should set_the_flash.to("Activity budget was successfully updated.") }
    end
    
    context "update percentage on successful request" do
      before :each do do_post("", "10") end    
      it { should redirect_to(activity_budget_path(@activity)) }
      it { should set_the_flash.to("Activity budget was successfully updated.") }
    end
  end
end

def do_post(amount = "10", percentage = "")
  post :update, :activity_id => @activity.id, 
              :activity => { :code_assignment_tree => ["1"], 
                             :budget_amounts => { "1" => { "a" => amount, "p" => percentage } } }
end
