require File.dirname(__FILE__) + '/../spec_helper'

describe UserSessionsController do
  context "attempt login with invalid user" do
    before :each do
      post :create
    end
    it { should respond_with(:success) }
    it { should set_the_flash.now }
    it { should render_template('static_page/index') }
  end

  context "login (create new session)" do
    before :each do
      @user = Factory.create(:reporter)
      post :create, :user_session => {:email => @user.email,
                                      :password => @user.password}
    end

    it { should redirect_to(dashboard_path) }
  end

  context "not logged in" do
    it "redirects the user to root path when requesting logout" do
      delete :destroy
      response.should redirect_to root_url
    end
  end
end
