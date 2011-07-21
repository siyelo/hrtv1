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
    it "DELETE with /admin/users/1" do
      params_from(:delete, "/admin/users/1").should == {:controller => "admin/users",
        :id => "1", :action => "destroy"}
    end
  end

  describe "Requesting Users endpoints as a member" do
    before :each do
      @organization = Factory(:organization)
      @data_request = Factory(:data_request, :organization => @organization)
      @sysadmin = Factory(:sysadmin, :organization => @organization)
      login @sysadmin
    end

    it "GET /admin/users should find all users in the org" do
      #activate_authlogic
      @request.env['HTTP_REFERER'] = 'http://localhost:3000/admin/users'
      get :index
      response.should be_success
    end

    it "POST /admin/users should create a user in the org" do
      params = {:full_name => 'bob rob', :email =>  'bob@siyelo.com', :role => ['reporter']}
      post :create, :user => params
      response.should be_success
    end
  end
end
