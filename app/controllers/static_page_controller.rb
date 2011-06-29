class StaticPageController < ApplicationController

  def index
    if current_user
      redirect_to user_dashboard_path(current_user)
    else
      render :layout => 'homepage'
    end
  end

  def about
  end
end

