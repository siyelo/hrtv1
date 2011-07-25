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


  #todo test creation of users from admin/users controller
  describe "Requesting Users endpoints as a member" do
    it "POST /admin/users should create a user in the org" do
      pending
    end
    
    it "should not allow you to create a DM without a location" do
      @dm = Factory.build(:district_manager, :location_id => nil)
      @dm.save.should be_false
    end
    
    it "should allow you to create a DM with a location" do
      @location = Factory(:location)
      @dm = Factory.build(:district_manager, :location => @location)
      @dm.save.should be_true
    end
    
    it "should not allow you to create a DM with a reporting organization" do
      @org = Factory(:reporting_organization)
      @dm = Factory.build(:district_manager, :organization => @org)
      @dm.save.should be_false
    end
    
    it "should allow you to create a DM with a non-reporting organization" do
      @org = Factory(:nonreporting_organization)
      @dm = Factory.build(:district_manager, :organization => @org)
      @dm.save.should be_true
    end
  end
end