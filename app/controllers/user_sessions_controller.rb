class UserSessionsController < ApplicationController
  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Successfully logged in."
      redirect_to static_page_path(:ngo_dashboard)
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


