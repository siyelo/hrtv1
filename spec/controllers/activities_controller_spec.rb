require File.dirname(__FILE__) + '/../spec_helper'

describe "Routing shortcuts for Activities (activities/1) should map" do
  controller_name :activities

  before(:each) do
    @activity = Factory.create(:activity)
    @activity.stub!(:to_param).and_return('1')
    @activities.stub!(:find).and_return(@activity)
  
    get :show, :id => "1"
  end
  
  it "activities_path to /activities" do
    activities_path.should == '/activities'
  end

  it "activity_path to /activities/1" do
    activity_path.should == '/activities/1'
  end
  
  it "activity_path(9) to /activities/9" do
    activity_path(9).should == '/activities/9'
  end

  it "edit_activity_path to /activities/1/edit" do
    edit_activity_path.should == '/activities/1/edit'
  end
  
  it "edit_activity_path(9) to /activities/9/edit" do
    edit_activity_path(9).should == '/activities/9/edit'
  end
  
  it "new_activity_path to /activities/new" do
    new_activity_path.should == '/activities/new'
  end
  
  it "approve_activity_path(9) to /activities/9/approve" do
    approve_activity_path(9).should == '/activities/9/approve'
  end
  
end


describe "Requesting Activity endpoints as visitor" do
  controller_name :activities

  context "RESTful routes" do
    context "Requesting /activities/ using GET" do
      before do get :index end
      it_should_behave_like "a protected endpoint"
    end 
  
    context "Requesting /activities/new using GET" do
      before do get :new end
      it_should_behave_like "a protected endpoint"
    end 
  
    context "Requesting /activities/1 using GET" do
      before do 
        @activity = Factory.create(:activity)
        get :show, :id => @activity.id
      end
      it_should_behave_like "a protected endpoint"
    end
    
    context "Requesting /activities/1/approve using POST" do
      before do 
        @activity = Factory.create(:activity)
        post :approve, :id => @activity.id
      end
      it_should_behave_like "a protected endpoint"
    end
  
    context "Requesting /activities using POST" do
      before do
        params = { :name => 'title', :description =>  'descr' }
        @activity = Factory.create(:activity, params )
        @activity.stub!(:save).and_return(true)
        post :create, :activity =>  params
      end
      it_should_behave_like "a protected endpoint"
    end
  
    context "Requesting /activities/1 using PUT" do
      before do
        params = { :name => 'title', :description =>  'descr' }
        @activity = Factory.create(:activity, params )
        @activity.stub!(:save).and_return(true)
        put :update, { :id => @activity.id }.merge(params)
      end
      it_should_behave_like "a protected endpoint"
    end
  
    context "Requesting /activities/1 using DELETE" do
      before do
        @activity = Factory.create(:activity)
        delete :destroy, :id => @activity.id
      end
      it_should_behave_like "a protected endpoint"
    end
  end
  
  context "ActiveScaffold" do
    context "GET methods" do
      before :each do
        @activity = Factory.create(:activity)
      end
  
      context "Requesting /activities/show_search using GET" do
        before do get :show_search, :id => @activity.id end
        it_should_behave_like "a protected endpoint"
      end 
  
      context "Requesting /activities/edit_associated using GET" do
        before do get :edit_associated, :id => @activity.id end
        it_should_behave_like "a protected endpoint"
      end
  
      context "Requesting /activities/new_existing using GET" do
        before do get :new_existing, :id => @activity.id end
        it_should_behave_like "a protected endpoint"
      end 
  
      context "Requesting /activities/list using GET" do
        before do get :list, :id => @activity.id end
        it_should_behave_like "a protected endpoint"
      end
  
      context "Requesting /activities/render_field using GET" do
        before do get :render_field, :id => @activity.id end
        it_should_behave_like "a protected endpoint"
      end
      
      context "Requesting /activities/1/row using GET" do
        before do get :row, :id => @activity.id end
        it_should_behave_like "a protected endpoint"
      end
      
      context "Requesting /activities/1/add_association using GET" do
        before do get :add_association, :id => @activity.id end
        it_should_behave_like "a protected endpoint"
      end
      
      context "Requesting /activities/1/edit_associated using GET" do
        before do get :edit_associated, :id => @activity.id end
        it_should_behave_like "a protected endpoint"
      end
      
      context "Requesting /activities/1/render_field using GET" do
        before do get :render_field, :id => @activity.id end
        it_should_behave_like "a protected endpoint"
      end
      
      context "Requesting /activities/1/nested using GET" do
        before do get :nested, :id => @activity.id end
        it_should_behave_like "a protected endpoint"
      end
      
      context "Requesting /activities/1/delete using GET" do
        before do get :delete, :id => @activity.id end
        it_should_behave_like "a protected endpoint"
      end
    end
  
    context "Requesting /activities/mark using PUT" do
      before do
        params = { :name => 'title', :description =>  'descr' }
        @activity = Factory.create(:activity, params )
        @activity.stub!(:save).and_return(true)
        put :mark, { :id => @activity.id }.merge(params)
      end
      it_should_behave_like "a protected endpoint"
    end
  
    context "Requesting /activities/add_existing_activities using POST" do
      before do
        params = { :name => 'title', :description =>  'descr' }
        @activity = Factory.create(:activity, params )
        @activity.stub!(:save).and_return(true)
        post :add_existing, :description =>  params
      end
      it_should_behave_like "a protected endpoint"
    end    
    
    context "Requesting /activities/1/update_column using POST" do
      before do
        params = { :name => 'title', :description =>  'descr' }
        @activity = Factory.create(:activity, params )
        @activity.stub!(:save).and_return(true)
        post :update_column, :id => @activity.id, :resource => params
      end
      it_should_behave_like "a protected endpoint"
    end
    
    context "Requesting /activities/1/destroy_existing using DELETE" do
      before do
        @activity = Factory.create(:activity)
        delete :destroy_existing, :id => @activity.id
      end
      it_should_behave_like "a protected endpoint"
    end
  end
end

describe "Requesting Activity endpoints as a reporter" do
  controller_name :activities
  
  before :each do
    @user = Factory.create(:reporter)
    login @user
    #@activity = Factory.create(:activity, :user => @user)
    @activity = Factory.create(:activity) #TODO add back user!
    @user_activities.stub!(:find).and_return(@activity)
  end
  
  context "Requesting /activities/ using GET" do
    it "should find the user" do
      pending
      User.should_receive(:find).with(1).and_return(@user)
      get :index, :user_id => 1
    end

    it "should assign the found user for the view" do
      pending
      get :index, :user_id => 1
      assigns[:user].should == @user
    end
    
    it "should assign the user_activities association as the activities" do
      pending
      @user.should_receive(:activities).and_return(@user_activities)
      get :index, :user_id => 1
      assigns[:user_activities].should == @user_activities
    end
  end
  
  context "Requesting /activities/1/approve using POST" do
    before do 
      @activity = Factory.create(:activity)
      post :approve, :id => @activity.id
    end
    it_should_behave_like "a protected endpoint"
  end
  
  context "Requesting /activities/new using GET" do
    it "should create a new activity for my user" do pending end
  end 

  context "Requesting /activities/1 using GET" do
    it "should get the activity if it belongs to me" do 
      pending 
      @activity = Factory.create(:activity)
      get :show, :id => @activity.id
    end
    it "should not get the activity if it does not belong to me " do pending end
  end

  context "Requesting /activities using POST" do
    before do
      params = { :name => 'title', :description =>  'descr' }
      @activity = Factory.build(:activity, params )
      @activity.stub!(:save).and_return(true)
      post :create, :record => params #AS expects :record, not :activity
    end
    it "should create a new activity under my user" do pending end
  end

  context "Requesting /activities/1 using PUT" do
    before do
      params = { :name => 'title', :description =>  'descr' }
      @activity = Factory.create(:activity, params )
      @activity.stub!(:save).and_return(true)
      put :update, :id => @activity.id, :record => params
    end
    it "should update the activity if it belongs to me" do pending end
    it "should not update the activity if it does not belong to me " do pending end
  end

  context "Requesting /activities/1 using DELETE" do
    before do
      @activity = Factory.create(:activity)
      delete :destroy, :id => @activity.id
    end
    it "should delete the activity if it belongs to me" do pending end
    it "should not delete the activity if it does not belong to me " do pending end
  end
end