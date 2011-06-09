class RegistrationsController < ApplicationController

  def edit
    @user = User.find(:first, :conditions => {:invite_token => params[:invite_token]})
    redirect_to root_url if params[:invite_token].nil? || @user.nil?
  end

  def update
    @user = User.find(:first, :conditions => {:invite_token => params[:invite_token]})
    @user.attributes = params[:user]

    if @user.activate
      flash[:notice] = "Thank you for registering on Health Resource Tracker."
      redirect_to root_url
    else
      render :edit
    end
  end
end
