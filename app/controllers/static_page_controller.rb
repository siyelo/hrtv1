class StaticPageController < ApplicationController
  layout 'promo_inner'

  def index
    if current_user
      redirect_to user_dashboard_path(current_user)
    else
      render :layout => 'promo_landing'
    end
  end

  def about
  end
end

