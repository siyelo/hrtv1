class StaticPageController < ApplicationController
  layout 'promo_landing'

  def index
    redirect_to dashboard_path if current_user
  end

  def about
  end
end

