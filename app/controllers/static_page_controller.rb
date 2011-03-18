class StaticPageController < ApplicationController
  def index
    render :layout => 'promo'
  end

  def about
  end
end

