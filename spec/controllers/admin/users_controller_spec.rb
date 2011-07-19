require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::UsersController do
  describe "Routing shortcuts should map" do
    it "GET (index) with admin/users" do
      params_from(:get, '/admin/users').should == { :controller => "admin/users",
        :action => "index"}
    end
    it "POST (create) with admin/users/new" do
      params_from(:post, '/admin/users/').should == {:controller => "admin/users",
        :action => "create"}
    end
    it "GET (edit) with admin/users/1/edit" do
      params_from(:get, '/admin/users/1/edit').should == {:controller => "admin/users",
        :id => "1", :action => "edit"}
    end
    it "DELETE with /organization/users/1" do
      params_from(:delete, "/admin/users/1").should == {:controller => "admin/users",
        :id => "1", :action => "destroy"}
    end
  end

  describe "Requesting Users endpoints as a member" do
    before :each do
      @reporter = Factory(:reporter)
      login @reporter
      ## Note: @response (and @request?) reserved by rspec
      @data_request = Factory(:data_request)
      @data_response = Factory(:data_response, :data_request => @data_request)
    end

    it "GET /organizations/users should find all users in the org" do
      #activate_authlogic
      @request.env['HTTP_REFERER'] = 'http://localhost:3000/admin/users'
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