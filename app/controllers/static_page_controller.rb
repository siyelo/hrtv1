class StaticPageController < ApplicationController
  before_filter :require_no_user

  def index
    render :layout => 'promo'
  end

  def about
  end
end

