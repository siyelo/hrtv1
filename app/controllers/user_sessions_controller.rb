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
      redirect_to user_dashboard_path(@user_session.record)
    else
      flash[:error] = "Wrong Username/email and password combination"
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "Successfully logged out."
    redirect_to new_user_session_url
  end
end


