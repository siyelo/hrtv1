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

  describe 'admin protected endpoints' do
    it "should search by current login date" do
      Timecop.freeze(Date.parse("2010-01-15"))
      @user1 = Factory :user
      login(@user1)
      Timecop.freeze(Date.parse("2010-02-20")) # Timecop seems to be doing a -1 on the date ?!

      @user2 = Factory :user
      login(@user2)
      Timecop.return
      login Factory(:admin)
      # sqlite doesnt support month names
      # so our test will have to use the SQLITE format to be safe
      # i.e. we cant use the form '19 Feb' in the query
      # Timecop seems to be doing a -1 on the date ?!
      get :index, :query => '19 02', :direction => 'asc'
      response.should render_template('admin/users/index')
      assigns(:users).should == [@user2]
    end
  end
end