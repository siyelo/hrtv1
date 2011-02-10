class ProfilesController < ApplicationController
  layout :set_layout

  before_filter :require_user, :load_user

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = 'Profile was successfully updated'
      redirect_to edit_profile_path
    else
      render :action => 'edit'
    end
  end

  private
    def load_user
      @user = current_user
    end
end
