require File.dirname(__FILE__) + '/../spec_helper'

describe "Routing shortcuts for FundingFlows (funding_flows/1) should map" do
  controller_name :funding_flows

  before(:each) do
    @funding_flow = Factory.create(:funding_flow)
    @funding_flow.stub!(:to_param).and_return('1')
    @funding_flows.stub!(:find).and_return(@funding_flow)

    get :show, :id => "1"
  end

  it "funding_flows_path to /funding_flows" do
    funding_flows_path.should == '/funding_flows'
  end

  it "funding_flow_path to /funding_flows/1" do
    funding_flow_path.should == '/funding_flows/1'
  end

  it "funding_flow_path(9) to /funding_flows/9" do
    funding_flow_path(9).should == '/funding_flows/9'
  end

  it "edit_funding_flow_path to /funding_flows/1/edit" do
    edit_funding_flow_path.should == '/funding_flows/1/edit'
  end

  it "edit_funding_flow_path(9) to /funding_flows/9/edit" do
    edit_funding_flow_path(9).should == '/funding_flows/9/edit'
  end

  it "new_funding_flow_path to /funding_flows/new" do
    new_funding_flow_path.should == '/funding_flows/new'
  end

end


describe "Requesting FundingFlow endpoints as visitor" do
  controller_name :funding_flows

  context "RESTful routes" do
    context "Requesting /funding_flows/ using GET" do
      before do get :index end
      it_should_behave_like "a protected endpoint"
    end

    context "Requesting /funding_flows/new using GET" do
      before do get :new end
      it_should_behave_like "a protected endpoint"
    end

    context "Requesting /funding_flows/1 using GET" do
      before do
        @funding_flow = Factory.create(:funding_flow)
        get :show, :id => @funding_flow.id
      end
      it_should_behave_like "a protected endpoint"
    end

    context "Requesting /funding_flows using POST" do
      before do
        params = { :project_id => 1,  :organization_id_from => 1, :organization_id_to => 2 }
        @funding_flow = Factory.create(:funding_flow, params )
        @funding_flow.stub!(:save).and_return(true)
        post :create, :funding_flow =>  params
      end
      it_should_behave_like "a protected endpoint"
    end

    context "Requesting /funding_flows/1 using PUT" do
      before do
        params = { :project_id => 1,  :organization_id_from => 1, :organization_id_to => 2 }
        @funding_flow = Factory.create(:funding_flow, params )
        @funding_flow.stub!(:save).and_return(true)
        put :update, { :id => @funding_flow.id }.merge(params)
      end
      it_should_behave_like "a protected endpoint"
    end

    context "Requesting /funding_flows/1 using DELETE" do
      before do
        @funding_flow = Factory.create(:funding_flow)
        delete :destroy, :id => @funding_flow.id
      end
      it_should_behave_like "a protected endpoint"
    end
  end

  context "ActiveScaffold" do
    context "GET methods" do
      before :each do
        @funding_flow = Factory.create(:funding_flow)
      end

      context "Requesting /funding_flows/show_search using GET" do
        before do get :show_search, :id => @funding_flow.id end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /funding_flows/edit_associated using GET" do
        before do get :edit_associated, :id => @funding_flow.id end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /funding_flows/new_existing using GET" do
        before do get :new_existing, :id => @funding_flow.id end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /funding_flows/list using GET" do
        before do get :list, :id => @funding_flow.id end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /funding_flows/render_field using GET" do
        before do get :render_field, :id => @funding_flow.id end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /funding_flows/1/row using GET" do
        before do get :row, :id => @funding_flow.id end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /funding_flows/1/add_association using GET" do
        before do get :add_association, :id => @funding_flow.id end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /funding_flows/1/edit_associated using GET" do
        before do get :edit_associated, :id => @funding_flow.id end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /funding_flows/1/render_field using GET" do
        before do get :render_field, :id => @funding_flow.id end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /funding_flows/1/nested using GET" do
        before do get :nested, :id => @funding_flow.id end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /funding_flows/1/delete using GET" do
        before do get :delete, :id => @funding_flow.id end
        it_should_behave_like "a protected endpoint"
      end
    end

    context "Requesting /funding_flows/mark using PUT" do
      before do
        params = { :project_id => 1,  :organization_id_from => 1, :organization_id_to => 2 }
        @funding_flow = Factory.create(:funding_flow, params )
        @funding_flow.stub!(:save).and_return(true)
        put :mark, { :id => @funding_flow.id }.merge(params)
      end
      it_should_behave_like "a protected endpoint"
    end

    context "Requesting /funding_flows/add_existing_funding_flows using POST" do
      before do
        params = { :project_id => 1,  :organization_id_from => 1, :organization_id_to => 2 }
        @funding_flow = Factory.create(:funding_flow, params )
        @funding_flow.stub!(:save).and_return(true)
        post :add_existing, :description =>  params
      end
      it_should_behave_like "a protected endpoint"
    end

    context "Requesting /funding_flows/1/update_column using POST" do
      before do
        params = { :project_id => 1,  :organization_id_from => 1, :organization_id_to => 2 }
        @funding_flow = Factory.create(:funding_flow, params )
        @funding_flow.stub!(:save).and_return(true)
        post :update_column, :id => @funding_flow.id, :resource => params
      end
      it_should_behave_like "a protected endpoint"
    end

    context "Requesting /funding_flows/1/destroy_existing using DELETE" do
      before do
        @funding_flow = Factory.create(:funding_flow)
        delete :destroy_existing, :id => @funding_flow.id
      end
      it_should_behave_like "a protected endpoint"
    end
  end
end

describe "Requesting FundingFlow endpoints as a reporter" do
  controller_name :funding_flows

  before :each do
    @user = Factory.create(:reporter)
    login @user
    #@funding_flow = Factory.create(:funding_flow, :user => @user)
    @funding_flow = Factory.create(:funding_flow) #TODO add back user!
    @user_funding_flows.stub!(:find).and_return(@funding_flow)
  end

  context "Requesting /funding_flows/ using GET" do
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

    it "should assign the user_funding_flows association as the funding_flows" do
      pending
      @user.should_receive(:funding_flows).and_return(@user_funding_flows)
      get :index, :user_id => 1
      assigns[:user_funding_flows].should == @user_funding_flows
    end
  end

  context "Requesting /funding_flows/new using GET" do
    #before do get :new end
    it "should create a new funding_flow for my user" do pending end
  end

  context "Requesting /funding_flows/1 using GET" do
    it "should get the funding_flow if it belongs to me" do
      pending
      @funding_flow = Factory.create(:funding_flow)
      get :show, :id => @funding_flow.id
    end
    it "should not get the funding_flow if it does not belong to me " do pending end
  end

  context "Requesting /funding_flows using POST" do
    before do
      params = { :project_id => 1,  :organization_id_from => 1, :organization_id_to => 2 }
      @funding_flow = Factory.build(:funding_flow, params )
      @funding_flow.stub!(:save).and_return(true)
      post :create, :record => params #AS expects :record, not :funding_flow
    end
    it "should create a new funding_flow under my user" do pending end
  end

  context "Requesting /funding_flows/1 using PUT" do
    before do
      params = { :project_id => 1,  :organization_id_from => 1, :organization_id_to => 2 }
      @funding_flow = Factory.create(:funding_flow, params )
      @funding_flow.stub!(:save).and_return(true)
      put :update, :id => @funding_flow.id, :record => params
    end
    it "should update the funding_flow if it belongs to me" do pending end
    it "should not update the funding_flow if it does not belong to me " do pending end
  end

  context "Requesting /funding_flows/1 using DELETE" do
    before do
      @funding_flow = Factory.create(:funding_flow)
      delete :destroy, :id => @funding_flow.id
    end
    it "should delete the funding_flow if it belongs to me" do pending end
    it "should not delete the funding_flow if it does not belong to me " do pending end
  end
end