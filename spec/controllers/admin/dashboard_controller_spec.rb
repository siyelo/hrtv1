require 'spec_helper'

describe Admin::DashboardController do

  context "as a visitor" do
    describe "it should be protected" do
      before :each do get :index end
      it { should redirect_to(login_path) }
      it { should set_the_flash.to("You must be an administrator to access that page") }
    end
  end
  
  context "as a reporter" do    
    before :each do
      @user = Factory.create(:reporter)
      login @user
    end
    
    describe "it should be protected" do
      before :each do get :index end
      it { should redirect_to(login_path) }
      it { should set_the_flash.to("You must be an administrator to access that page") }
    end
  end  
  
  context "as a sysadmin" do    
    before :each do
      @admin = Factory.create(:sysadmin)
      login @admin
    end
    
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end
  
end