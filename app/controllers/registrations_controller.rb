class RegistrationsController < ApplicationController
  
  def edit
    @user = User.find(:first, :conditions => {:invite_token => params[:invite_token]})
  end
  
  def update
    
  end
end
