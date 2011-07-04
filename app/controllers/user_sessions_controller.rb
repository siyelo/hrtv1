class UserSessionsController < ApplicationController
  layout 'promo_inner'

  before_filter :require_no_user, :only => [:new]
  before_filter :require_user, :only => [:destroy]
  skip_before_filter :load_help

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_to dashboard_path
    else
      flash.now[:error] = "Wrong Username/email and password combination. If you think this message is being shown in error after multiple tries, use the form on the contact page (link below) to get help."
      render :action => :new
    end
  end

  def destroy
    self.send(:current_user_session).destroy
    flash[:notice] = "Successfully signed out."
    redirect_to root_url
  end
end
