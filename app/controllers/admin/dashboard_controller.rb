class Admin::DashboardController < ApplicationController
  before_filter :require_admin
  skip_before_filter :load_help

  def index
    @comments = Comment.find(:all, :order => 'created_at DESC', :limit => 5)
  end
end
