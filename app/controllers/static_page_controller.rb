class StaticPageController < ApplicationController
  before_filter :require_no_user

  def index
    render :layout => 'homepage'
  end

  def about
  end
end

