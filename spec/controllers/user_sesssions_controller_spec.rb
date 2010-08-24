require File.dirname(__FILE__) + '/../spec_helper'

describe UserSessionsController do
  
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
 
  context "attempt login with invalid user" do    
    before :each do
      post :create
    end
    
    it { should respond_with(:success) }
    it { should set_the_flash.to("Wrong Username/email and password combination. If you think this message is being shown in error after multiple tries, use the form on the contact page (link below) to get help.") }
    it { should render_template(:new) }
  end
  
  context "login (create new session)" do    
    before :each do
      @user = Factory.create(:reporter)
      post :create, :user_session => { :username => @user.username, :password => @user.password}
    end

    it { should set_the_flash.to("Successfully logged in.") }
    it { should redirect_to(static_page_url(:ngo_dashboard)) }
  end
  
end