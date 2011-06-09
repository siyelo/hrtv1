require File.dirname(__FILE__) + '/../../spec_helper'

describe Organization::UsersController do
  describe "Routing shortcuts should map" do
    it "GET (index) with /organization/members" do
      params_from(:get, '/organization/members').should == { :controller => "organization/users",
        :action => "index"}
    end
    it "POST (create) with /organization/members/new" do
      params_from(:post, '/organization/members/').should == {:controller => "organization/users",
        :action => "create"}
    end
    it "GET (edit) with /organization/members/1/edit" do
      params_from(:get, '/organization/members/1/edit').should == {:controller => "organization/users",
        :id => "1", :action => "edit"}
    end
    it "DELETE with /organization/members/1" do
      params_from(:delete, "/organization/members/1").should == {:controller => "organization/users",
        :id => "1", :action => "destroy"}
    end
  end

  describe "Requesting Users endpoints as a member" do
    before :each do
      @reporter = Factory.create(:reporter)
      login @reporter
      ## Note: @response (and @request?) reserved by rspec
      @data_request = Factory(:data_request)
      @data_response = Factory.create(:data_response, :data_request => @data_request)
    end

    it "GET /organizations/users should find all users in the org" do
      #activate_authlogic
      get :index
      response.should be_success
    end

    it "POST /organizations/users should create a user in the org" do
      params = {:full_name => 'bob rob', :email =>  'bob@siyelo.com', :role => ['reporter']}
      @user = User.new()
      @user.stub!(:save).and_return(true)
      post :create, :user => params
      response.should be_success
    end
  end

  describe "Requesting Users endpoints as a org admin" do
  end

  describe "Requesting Users endpoints as a visitor" do
  end
end