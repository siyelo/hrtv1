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
    it { should set_the_flash.now }
    it { should render_template(:new) }
  end

  context "authenticated login (create new session)" do
    before :each do
      @user = Factory.create(:reporter)
      post :create, :user_session => {:email => @user.email,
                                      :password => @user.password}
    end

    it { should redirect_to(reporter_dashboard_path) }

    it "redirects the user to their dashboar when requesting the login form" do
      get :new
      response.should redirect_to reporter_dashboard_path
    end
  end

  context "not logged in" do
    it "redirects the user to root path when requesting logout" do
      delete :destroy
      response.should redirect_to login_path
    end
  end
end
