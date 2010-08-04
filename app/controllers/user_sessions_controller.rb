class UserSessionsController < ApplicationController
  skip_before_filter :load_help
  include UsersHelper
  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Successfully logged in."
      redirect_to static_page_url(:user_guide)
    else
      flash[:error] = "Wrong Username/email and password combination. If you think this message is being shown in error after multiple tries, use the form on the contact page (link below) to get help."
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "Successfully logged out."
    redirect_to root_url
  end
end


