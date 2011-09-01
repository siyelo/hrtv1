class UserSessionsController < ApplicationController
  layout 'promo_landing'

  before_filter :require_user, :only => [:destroy]

  def create
    @user_session = UserSession.new(params[:user_session])

    if @user_session.save
      redirect_back_or_default dashboard_path
    else
      flash.now[:error] = "Wrong Email or Password."
      render :template => 'static_page/index'
    end
  end

  def destroy
    self.send(:current_user_session).destroy
    flash[:notice] = "Successfully signed out."
    redirect_to root_url
  end
end
