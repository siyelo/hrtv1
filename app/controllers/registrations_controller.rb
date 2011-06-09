class RegistrationsController < ApplicationController
  
  def edit
    @user = User.find(:first, :conditions => {:invite_token => params[:invite_token]})
    redirect_to root_url if params[:invite_token].nil? || @user.nil?
  end
  
  def update
    @user = User.find(:first, :conditions => {:invite_token => params[:invite_token]})
    if @user.update_attributes(params[:user])
      @user.invite_token = nil
      @user.save
      flash[:notice] = "Thank you for registering on Health Resource Tracker."
      redirect_to root_url
    else
      render :edit
    end
  end
end
